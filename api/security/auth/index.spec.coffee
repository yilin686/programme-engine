_ = require 'lodash'
Promise = require 'bluebird'
moment = require 'moment'
faker = require 'faker'
sinon = require 'sinon'
snakeize = require 'snakeize'
express = require '../../express'
bodyParser = require 'body-parser'
testFixtures = require '../../../utils/testFixtures'
User = require '../../../core/models/user'
OAuth2Client = require './oauth2Client'
auth = require './'

describe 'api.security.auth', ->
  app = express()
  app.use bodyParser.json()
  app.use bodyParser.urlencoded(extended: true)
  app.use auth.initialize()
  app.post '/oauth/token', auth.token
  
  supertest = require('../../utils/supertest')(app)

  checkTokenResponse = (res) ->
    res.status.should.equal 200
    res.body.should.have.keys 'access_token', 'refresh_token', 'expires_in', 'token_type'
    res.body.should.have.property 'token_type', 'Bearer'

  before -> do testFixtures.init
  beforeEach -> do testFixtures.reset

  # 创建一个`client`和一个`user`
  beforeEach ->
    ctx = @
    password = faker.internet.password()
    Promise
      .all [
        OAuth2Client.create {name: faker.name.findName(), secret: faker.internet.password()}
        User.insertTestUsers(1, {password}).get(0)
      ]
      .then ([client, user]) ->
        ctx.client = client
        ctx.user = user
        ctx.params =
          grant_type: 'password'
          client_id: ctx.client.id
          client_secret: ctx.client.secret
          username: ctx.user.username
          password: password

  describe '获取`access token`', ->
    it '发送正确的参数应获得`access token`', ->
      ctx = @
      supertest
        .post '/oauth/token'
        .send ctx.params
        .then checkTokenResponse

    it '密码错误时获取`access token`应该失败', ->
      ctx = @
      ctx.params.password = faker.internet.password()
      supertest
        .post '/oauth/token'
        .send ctx.params
        .then (res) ->
          res.status.should.equal 403

    it '应该允许使用`Http Basic`验证方式验证客户端', ->
      ctx = @
      params = _.omit ctx.params, 'client_id', 'client_secret'
      supertest
        .post '/oauth/token'
        .auth ctx.params.client_id, ctx.params.client_secret
        .send params
        .then checkTokenResponse

    it '使用`refresh token`获取新的`access token`', ->
      ctx = @
      supertest
        .post '/oauth/token'
        .send ctx.params
        .then (res) ->
          supertest
            .post '/oauth/token'
            .send {
              grant_type: 'refresh_token'
              client_id: ctx.client.id
              client_secret: ctx.client.secret
              refresh_token: res.body.refresh_token
            }
        .then checkTokenResponse

    it '错误的`refresh token`应该无法获取新的`access token`', ->
      ctx = @
      supertest
        .post '/oauth/token'
        .send {
          grant_type: 'refresh_token'
          client_id: ctx.client.id
          client_secret: ctx.client.secret
          refresh_token: faker.token(32)
        }
        .then (res) ->
          res.status.should.equal 403

  describe '访问受限资源', ->
    before ->
      app.get '/user', auth.bearer, (req, res) -> res.json req.user

    beforeEach ->
      ctx = @
      supertest
        .post '/oauth/token'
        .send ctx.params
        .then (res) ->
          ctx.token = res.body

    it '无`access token`应收到401', ->
      supertest
        .get '/user'
        .then (res) ->
          res.status.should.equal 401

    it '无效`access token`应收到401', ->
      supertest
        .get '/user'
        .set 'Authorization', "bearer #{faker.token(32)}"
        .then (res) ->
          res.status.should.equal 401

    it '正确`access token`应获取到资源', ->
      ctx = @
      supertest
        .get '/user'
        .set 'Authorization', "bearer #{ctx.token.access_token}"
      .then (res) ->
        res.status.should.equal 200
        expected = snakeize ctx.user
        res.body.should.deep.equal expected

    describe '`access token`过期', ->
      beforeEach ->
        ctx = @
        ctx.clock = sinon.useFakeTimers()
        supertest
          .post '/oauth/token'
          .send ctx.params
          .then (res) ->
            ctx.token = res.body
            ctx.clock.tick ctx.token.expires_in * 1000 + 1

      afterEach ->
        @clock.restore()

      it '过期后应该无法访问', ->
        ctx = @
        supertest
          .get '/user'
          .set 'Authorization', "bearer #{ctx.token.access_token}"
          .then (res) ->
            res.status.should.equal 401

      it '过期后可以使用`refresh token`获取新的`access token`', ->
        ctx = @
        supertest
          .post '/oauth/token'
          .send {
            grant_type: 'refresh_token'
            client_id: ctx.client.id
            client_secret: ctx.client.secret
            refresh_token: ctx.token.refresh_token
          }
          .then checkTokenResponse

      it '新的`access token`应该有效', ->
        ctx = @
        supertest
          .post '/oauth/token'
          .send {
            grant_type: 'refresh_token'
            client_id: ctx.client.id
            client_secret: ctx.client.secret
            refresh_token: ctx.token.refresh_token
          }
          .then (res) ->
            supertest
              .get '/user'
              .set 'Authorization', "bearer #{res.body.access_token}"
          .then (res) ->
            res.status.should.equal 200

    describe '`scope`权限', ->
      before ->
        roles = ['admin', 'user']

        scopes = ['org', 'org_admin']

        permissions =
          admin: ['org', 'org_admin']
          user: ['org']

        auth.scope.initialize roles, scopes, permissions

        app.get '/orgs', auth.bearer, auth.scope('org'), (req, res) -> res.sendStatus 200
        app.post '/orgs', auth.bearer, auth.scope('org_admin'), (req, res) -> res.sendStatus 200

      it '有`scope`权限的用户应允许访问', ->
        ctx = @
        supertest
          .get '/orgs'
          .set 'Authorization', "bearer #{ctx.token.access_token}"
          .then (res) ->
            res.status.should.equal 200

      it '无`scope`权限的用户应无法访问', ->
        ctx = @
        supertest
          .post '/orgs'
          .set 'Authorization', "bearer #{ctx.token.access_token}"
          .then (res) ->
            res.status.should.equal 403

      it '为资源指定不存在的`scope`应该出错', ->
        (-> app.get '/orgs', auth.bearer, auth.scope('not_exists')).should.throw ReferenceError

  describe '访问公开资源', ->
    before ->
      app.get '/public', (req, res) -> res.sendStatus 200

    it '无`token`应允许访问', ->
      supertest
        .get '/public'
        .then (res) ->
          res.status.should.equal 200

    it '有`access token`时应允许访问', ->
      ctx = @
      supertest
        .post '/oauth/token'
        .send ctx.params
        .then (res) ->
          supertest
            .get '/user'
            .set 'Authorization', "bearer #{res.body.access_token}"
        .then (res) ->
          res.status.should.equal 200
