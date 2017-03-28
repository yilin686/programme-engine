_ = require 'lodash'

conf =
  default:
    server:
      protocol: 'http'
      host: 'localhost'
      port: 6100
  production:
    server:
      protocol: 'http'
      host: 'radiolibs.com/programme-engine'
      port: 6000
    db: 'mongodb://localhost/programme-engine'
  development:
    server:
      host: 'localhost'
      port: 6100
    db: 'mongodb://localhost/programme-engine-dev'
  test:
    server:
      host: 'localhost'
      port: 6200
    db: 'mongodb://localhost/programme-engine-test'

module.exports = _.merge conf.default, conf[process.env.NODE_ENV]
