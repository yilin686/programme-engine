###*
  @module api
  @class api.errors
###
module.exports =
  ###*
    常见Http错误的集合, 可以通过状态码获取对应的Class, 例如`errors.HttpErrors[404]`

    @static
    @property {Array} HttpErrors
  ###
  HttpErrors: require './httpErrors'
