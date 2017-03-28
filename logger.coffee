winston = require 'winston'
moment = require 'moment'

module.exports = new winston.Logger {
  transports: [
    new winston.transports.Console {
      timestamp: -> moment().format()
      formatter: (opts) ->
        "#{opts.timestamp()} #{opts.level.toUpperCase()} #{opts.message or ''}" +
          (opts.meta and Object.keys(opts.meta).length and '\n' + JSON.stringify(opts.meta) or '')
    }
  ]
}
