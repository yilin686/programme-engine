_ = require 'lodash'
Errors = require '../errors'

module.exports = (err, req, res, next) ->
  if err.name is 'ValidationError' # `mongoose`和`joi`的验证错误都使用这个`name`
    message = err.errors or err.message
    err = new Errors.HttpErrors[400](message)

  if err instanceof Errors.HttpErrors.HttpError
    res
      .status err.code
      .json _.pick err, ['code', 'message']
  else
    next err
