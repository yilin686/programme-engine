process.env.NODE_ENV ?= 'development'

express = require 'express'
host = require './host'
logger = require './logger'
config = require './conf'

app = express()

host.start {app, config}
  .then ->
    app.listen config.server.port, (err) ->
      if err
        throw err
      else
        logger.info "programme-engine服务已启动, 端口:#{config.server.port}"
