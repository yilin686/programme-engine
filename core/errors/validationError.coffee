util = require 'util'

###*
  @module core
###

###*
  用于描述验证错误

  @class core.errors.ValidationError
  @constructor
  @param {String} message
###
ValidationError = (message) ->
  Error.call @, message
  Error.captureStackTrace @, @constructor

  ###*
    @property {String} message
  ###
  @message = message

  ###*
    用于兼容`mongoose`和`joi`的错误处理, 始终为`ValidationError`
    @property {String} name
  ###
  @name = 'ValidationError'

util.inherits ValidationError, Error

module.exports = ValidationError
