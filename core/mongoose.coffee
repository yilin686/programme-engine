Promise = require 'bluebird'
_ = require 'lodash'
joi = require 'joi'
validate = require '../utils/validate'

###*
  `models`下的所有模型共用的独立的`Mongoose`实例对象, 与`mongoose`的默认实例分隔开

  @class core.mongoose
  @extends mongoose
###

mongoose = new (require('mongoose').Mongoose)
mongoose.Promise = Promise

###*
  扩展默认的`mongoose.Query`

  @class core.mongoose.Query
  @extends mongoose.Query
###

###*
  对查询进行分页

  @method paginate
  @param {Object} opts
  @return {Promise}
###
mongoose.Query.prototype.paginate = (opts = {}) ->
  opts = validate.sanitize opts, {
    page: joi.number().integer().default(1)
    perPage: joi.number().integer().max(50).default(10)
  }

  {page, perPage} = opts

  query = @toConstructor()
  Promise
    .all [
      query().count()
      @skip((page - 1) * perPage).limit(perPage).exec()
    ]
    .then ([total, docs]) ->
      pagination: {total, page, perPage}
      docs: docs.map (doc) -> doc.toObject()

# 提供默认的Schema创建参数
defaultSchemaOptions =
  strict: 'throw'
  toObject:
    retainKeyOrder: true

__Schema = mongoose.Schema
mongoose.Schema = (definition, opts) ->
  new __Schema definition, _.merge(opts, defaultSchemaOptions)
_.merge mongoose.Schema, __Schema

mongoose.connection.on 'error', (err) ->
  throw err

module.exports = mongoose
