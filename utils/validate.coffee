joi = require 'joi'
_ = require 'lodash'
mongoose = require '../core/mongoose'
ValidationError = require '../core/errors/validationError'

###*
  @module utils
###

###*
  验证工具

  @class utils.validate
###

###*
  验证某个值或多个值必须存在, 不存在时抛出异常

  @method required
  @param {Arguments|Array} values
  @throws {ValidationError}
###
module.exports.required = (values...) ->
  for val in values
    {error} = joi.required().validate val
    if error
      throw new ValidationError error.message
  return

###*
  按照`schema`验证`value`, 验证失败时抛出异常

  @method try
  @param value
  @param {joi.Schema} schema
  @throws {ValidationError}
###
module.exports.try = (value, schema, options = {}) ->
  @required value, schema
  {error} = joi.compile(schema).validate value, _.extend(convert: false, options)
  if error
    throw new ValidationError error.message

###*
  按照`schema`验证并转换`value`, 返回转换后的值, 验证失败时抛出异常

  @method sanitize
  @param value
  @param {joi.Schema} schema
  @throws {ValidationError}
###
module.exports.sanitize = (value, schema) ->
  @required value, schema
  {error, value: ret} = joi.compile(schema).validate value
  if error
    throw new ValidationError error.message
  else
    ret

###*
  验证对象中是否只包含可选的`key`, 存在多余`key`时抛出异常

  @method optionalKeys
  @param {Object} value
  @param {Array<String>} keys
  @throws {ValidationError}
###
module.exports.optionalKeys = (value, keys...) ->
  validateSchema = _.zipObject keys, (joi.optional() for [1..keys.length])
  @try value, validateSchema

###*
  验证对象中是否包含必选的`key`, 允许存在多余`key`

  @method requireKeys
  @param {Object} value
  @param {Array<String>} keys
  @throws {ValidationError}
###
module.exports.requireKeys = (value, keys...) ->
  validateSchema = _.zipObject keys, (joi.required() for [1..keys.length])
  @try value, validateSchema, {allowUnknown: true}

###*
  验证对象的全部`key`是否符合预期

  @method requireAllKeys
  @param {Object} value
  @param {Array<String>} keys
  @throws {ValidationError}
###
module.exports.requireAllKeys = (value, keys...) ->
  validateSchema = _.zipObject keys, (joi.required() for [1..keys.length])
  @try value, validateSchema

###*
  判断一个对象或者字符串是否为`ObjectId`

  @method isObjectId
  @param {Object|String} v
  @return {Boolean}
###
joi.objectId = ->
  joi.compile [
    joi.string().regex /^[0-9a-fA-F]{24}$/
    joi.object().type require('mongoose').Types.ObjectId
  ]
