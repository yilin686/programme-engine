_ = require 'lodash'
Promise = require 'bluebird'
moment = require 'moment'
crypto = require 'crypto'
joi = require 'joi'
validate = require './validate'
mongoose = require('../core').mongoose
conf = require '../conf'

###*
  @module utils
###

###*
  测试设施

  @class utils.testFixtures
###

initChai = ->
  chai = require 'chai'
  chai.should()
  chai.use require('chai-as-promised')

  like = require('chai-like')
  like.extend {
    match: (object) ->
      _.isDate object
    assert: (object, expected) ->
      moment(object).isSame(expected)
  }
  chai.use like

initFaker = ->
  faker = require 'faker'

  # 重写`faker.internet.userName`
  __userName = faker.internet.userName
  faker.internet.userName = (min = 6, max = 32) ->
    validate.try min, joi.number().integer().required()
    validate.try max, joi.number().integer().min(min).required()
    username = __userName.call(@).replace(/\W/, '_')
    username = _.padRight(username, min, faker.random.alphaNumeric())[0...max]
    username

  faker.objectId = -> new mongoose.Types.ObjectId

  faker.token = (length = 32) -> crypto.randomBytes(length).toString('hex')

initMongoose = ->
#  mongoose.set 'debug', true
  mongoose.connect conf.db

initializer = Promise.all [
  initChai()
  initFaker()
  initMongoose()
]

###*
  初始化测试设施

  @method init
###
module.exports.init = -> initializer

###*
  重置测试设施到初始状态

  @method reset
###
module.exports.reset = ->
  Promise.all (
    for name in mongoose.connection.modelNames()
      mongoose.model(name).remove()
  )
