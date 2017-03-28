express = require './express'
bodyParser = require 'body-parser'

app = express()

if process.env.NODE_ENV is 'development'
  app.use require('morgan')('dev')

app.use bodyParser.json(limit: '3mb')
app.use bodyParser.urlencoded(limit: '3mb', extended: true)
app.use require('method-override')()
app.use require('./middlewares/camelizeParams')
app.use require('./middlewares/requestContext')
app.use require('./routes')
app.use require('./middlewares/errorHandler')

#if process.env.NODE_ENV is 'development'
app.use require('errorhandler')(log: true)

module.exports = app
