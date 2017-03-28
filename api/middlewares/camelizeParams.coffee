_ = require 'lodash'
camelize = require 'camelize'

###
  将`request`对象中的参数转换为`camelCase`形式
###
module.exports = (req, res, next) ->
  req.query = camelize req.query
  req.body = camelize req.body
  req.params = camelize req.params
  next()
