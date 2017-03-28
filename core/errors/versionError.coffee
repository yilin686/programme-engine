util = require 'util'

###*
  @module core
###

###*
  用于描述更新时发生版本冲突

  @class core.errors.VersionError
  @constructor
  @param {String} message
###
VersionError = (message) ->
  Error.call @, message
  Error.captureStackTrace @, @constructor

  ###*
    @property {String} message
  ###
  @message = message

  ###*
    @property {String} name
  ###
  @name = 'VersionError'

util.inherits VersionError, Error

module.exports = VersionError
