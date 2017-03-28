express = require 'express'
mongoose = require('./core').mongoose
Promise = require 'bluebird'

logger = require './logger'

NODE_ENV = process.env.NODE_ENV

start = (options) ->
  logger.info "系统启动, 运行环境: #{NODE_ENV}..."
  options = options or {}
  options.config = options.config or require './conf'
  initMongoose(options)
    .then -> initExpress(options)
    .then -> logger.info '系统启动成功'
      
initMongoose = (options) ->
  logger.info '初始化Mongoose...'

  mongoose.set 'debug', true if NODE_ENV is 'development'
  
  mongoose.connect(options.config.db)
    .then ->
      logger.info '初始化Mongoose成功'
      process.on 'exit', -> mongoose.disconnect()
    
initExpress = (options) ->
  logger.info '初始化Express...'
  app = options.app ?= express()
  app.use '/programme', require './api'
  
  logger.info '初始化Express成功'
  
module.exports = {start}
