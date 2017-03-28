_ = require 'lodash'
Promise = require 'bluebird'
joi = require 'joi'
mongoose = require '../mongoose'
validate = require '../../utils/validate'
ValidationError = require '../errors/validationError'

###*
  @class core.models.Programme
###

Programme = mongoose.model 'Programme', require('./programme.schema')

validateSchema =
  channel: joi.objectId()
  date: joi.date()
  rule: joi.objectId()
  clocks: joi.array().items(joi.object())

###*
  `Programme`的验证`Schema`

  @static
  @property {Joi} validateSchema
###
module.exports.validateSchema = validateSchema

###*
  创建新`Programme`

  @static
  @method create
  @throws {ValidationError}
  @param {Object} programmeToCreate
  @return {Promise} `resolve`时返回新创建的`Programme`对象
###
module.exports.create = (programmeToCreate) ->
  programmeToCreate = validate.sanitize programmeToCreate, validateSchema
  Programme
    .create programmeToCreate
    .then (programme) -> programme.toObject()
    .catch (err) ->
      throw err

###*
  根据`channelId`和`date`获取`Programme`

  @static
  @method get
  @param {ObjectId} channelId
  @param {Date} date
  @return {Promise} `resolve`时返回`Programme`, 没有找到时返回`undefined`
  @throws {ValidationError}
###
module.exports.get = (channelId, date) ->
  date = date.toDate()
  channelId = validate.sanitize channelId, joi.objectId()
  date = validate.sanitize date, joi.date()
  Programme
    .findOne
      channel: channelId
      date: date
      __deleted: false
    .then (programme) -> programme?.toObject()

###*
  根据`channelId`和`date`获取`Programme`, 如果没有就创建新的`Programme`

  @static
  @method get
  @param {ObjectId} channelId
  @param {Date} date
  @return {Promise} `resolve`时返回`Programme`, 没有找到时返回`undefined`
  @throws {ValidationError}
###
module.exports.findOrCreate = (channelId, date) ->
  self = @
  self.get channelId, date
    .then (programme) ->
      if programme
        programme
      else
        self.create
          channel: channelId
          date: date.toDate()
          clocks: {} for [1..24]
        .then (programme) ->
          programme

###*
  根据`channelId`和`date`获取`Programme`, 更新`Programme`中`clocks`字段指定`index`的`items`

  @static
  @method get
  @param {ObjectId} channelId
  @param {Date} date
  @param {Number} index
  @param {Array} items
  @return {Promise} `resolve`时返回`Programme`, 没有找到时返回`undefined`
  @throws {ValidationError}
###
module.exports.updateOfClocks = (channelId, date, index, items) ->
  self = @
  self.get channelId, date
    .then (programme) ->
      if not programme
        throw new ValidationError '`Programme`不存在'
      else
        programme.clocks[index].items = items
        programme.save()
    .then (programme) ->
      programme?.toObject()