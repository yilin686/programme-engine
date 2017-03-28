express = require 'express'
_ = require 'lodash'
joi = require 'joi'
url = require 'url'
snakeize = require 'snakeize'
validate = require '../utils/validate'
conf = require '../conf'

###*
  @module api
###

###*
  @class api.express.response
  @extends express.response
###

generatePageLink = (requestUrl, page, perPage) ->
  urlObj = url.parse requestUrl, true
  delete urlObj.search
  urlObj.protocol = conf.server.protocol
  urlObj.host = conf.server.host
  urlObj.query.page = page
  urlObj.query.per_page = perPage
  url.format urlObj

###*
  把分页数据转换为Http响应

  @method paginate
  @param {Request} req
  @param {Object} pagination
  @param {Array} docs
###
express.response.paginate = (req, pagination, docs) ->
  validate.try pagination, {
    total: joi.number().integer().required()
    page: joi.number().integer().required()
    perPage: joi.number().integer().required()
  }
  validate.try docs, joi.array().required()

  @set {
    'X-Total': pagination.total
    'X-Page': pagination.page
    'X-Per-Page': pagination.perPage
  }

  {total, page, perPage} = pagination
  last = Math.ceil(total / perPage)

  if page > 1
    @links {
      first: generatePageLink req.originalUrl, 1, perPage
      prev: generatePageLink req.originalUrl, page - 1, perPage
    }

  if page < last
    @links {
      next: generatePageLink req.originalUrl, page + 1, perPage
      last: generatePageLink req.originalUrl, last, perPage
    }

  @json docs

###*
  重写了`res.json`方法, 把对象的键名转换为`snake case`形式

  @method json
###
__json = express.response.json
express.response.json = (obj) ->
  __json.call @, snakeize(obj)

###*
  重写了`res.send`方法, 把对象的键名转换为`snake case`形式

  @method send
###
__send = express.response.send
express.response.send = (obj) ->
  __send.call @, snakeize(obj)

module.exports = express
