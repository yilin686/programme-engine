
###
  给`req`附加一个`ctx`属性用于存储上下文信息
###
module.exports = (req, res, next) ->
  req.ctx ?= {}
  next()
