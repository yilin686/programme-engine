moment = require 'moment'
passport = require 'passport'
User = require '../../../core/models/user'
OAuth2Token = require './oauth2Token'
conf = require '../../../conf'

###*
  @module api
###

###*
  基于`oauth 2.0`的用户认证&权限管理模块

  @class api.security.auth
###

###*
  初始化用户认证系统

  @method initialize
  @return {Function}
  @example
    ```
      app.use auth.initialize()
    ```
###
module.exports.initialize = ->
  BearerStrategy = require('passport-http-bearer').Strategy
  passport.use (
    new BearerStrategy (accessToken, done) ->
      OAuth2Token.findOne {accessToken}
        .then (token) ->
          if not token
            done null, false
          else
            expireTime = moment(token.createdAt).add(conf.security.tokenLife, 's')
            if moment().isAfter expireTime
              done null, false, {message: 'Token expired'}
            else
              User.get token.userId
                .then (user) ->
                  if not user
                    done null, false
                  else
                    done null, user
        .catch done
  )

  passport.initialize()


###*
  `Bearer`认证中间件

  @property {Function} bearer
  @example
    ```
      app.get '/user', auth.bearer, (req, res) -> res.json req.user
    ```
###
module.exports.bearer = passport.authenticate 'bearer', {session: false}


###*
  `token`授权服务

  @property {Function} token
  @example
    ```
      app.use '/oauth/token', auth.token
    ```
###
module.exports.token = require('./oauth2').token


###*
  `scope`设置中间件, 需要初始化之后才能使用

  @method scope
  @return {Function}
  @example
    ```
      roles = ['admin', 'user']
      scopes = ['org', 'org_admin']
      permissions =
        admin: ['org', 'org_admin']
        user: ['org']
      auth.scope.initialize roles, scopes, permissions

      app.get '/orgs', auth.bearer, auth.scope('org'), (req, res) ->
        # List organizations
    ```
###
module.exports.scope = require './oauth2Scope'
