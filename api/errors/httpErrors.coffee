util = require 'util'

###*
  @module api
###

###*
  用于描述Http错误, 具体的Http错误可以通过`errors.HttpErrors[{code}]`获得

  @class api.errors.HttpErrors.HttpError
  @constructor
  @param {String} message
  @param {Number} code http status code

  @example
    ```coffeescript
      throw new errors.HttpErrors[404]
    ```
###
exports.HttpError = (message, code) ->
  Error.call this, message
  #Error.captureStackTrace(this, arguments.callee);

  ###*
    @property {String} message
  ###
  @message = message

  ###*
    Http Status Code
    @property {Number} code
  ###
  @code = code
  return

util.inherits exports.HttpError, Error

###*
  @method toString
###
exports.HttpError::toString = ->
  @message

###*
  @method toJSON
###
exports.HttpError::toJSON = ->
  code: @code
  status: @defaultMessage
  message: @message


###
  通过代码为每个Http错误生成对应的Class
###
statusCodes =
  400: 'Bad Request'
  401: 'Unauthorized'
  402: 'Payment Required'
  403: 'Forbidden'
  404: 'Not Found'
  405: 'Method Not Allowed'
  406: 'Not Acceptable'
  407: 'Proxy Authentication Required'
  408: 'Request Timeout'
  409: 'Conflict'
  410: 'Gone'
  411: 'Length Required'
  412: 'Precondition Failed'
  413: 'Request Entity Too Large'
  414: 'Request-URI Too Long'
  415: 'Unsupported Media Type'
  416: 'Requested Range Not Satisfiable'
  417: 'Expectation Failed'
  420: 'Enhance Your Calm'
  422: 'Unprocessable Entity'
  423: 'Locked'
  424: 'Failed Dependency'
  425: 'Unordered Collection'
  426: 'Upgrade Required'
  428: 'Precondition Required'
  429: 'Too Many Requests'
  431: 'Request Header Fields Too Large'
  444: 'No Response'
  449: 'Retry With'
  499: 'Client Closed Request'
  500: 'Internal Server Error'
  501: 'Not Implemented'
  502: 'Bad Gateway'
  503: 'Service Unavailable'
  504: 'Gateway Timeout'
  505: 'HTTP Version Not Supported'
  506: 'Variant Also Negotiates'
  507: 'Insufficient Storage'
  508: 'Loop Detected'
  509: 'Bandwidth Limit Exceeded'
  510: 'Not Extended'
  511: 'Network Authentication Required'

toCamelCase = (str) ->
  str.toLowerCase().replace /(?:(^.)|(\s+.))/g, (match) ->
    match.charAt(match.length - 1).toUpperCase()

for status of statusCodes
  defaultMsg = statusCodes[status]
  error = do (defaultMsg, status) ->
    (msg) ->
      @defaultMessage = defaultMsg
      exports.HttpError.call this, msg or status + ': ' + defaultMsg, status
      if status >= 500
        Error.captureStackTrace this, arguments.callee
      return
  util.inherits error, exports.HttpError
  className = toCamelCase(defaultMsg)
  exports[className] = error
  exports[status] = error
