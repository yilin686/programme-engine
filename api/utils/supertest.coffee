Promise = require 'bluebird'
methods = require 'methods'
supertest = require('supertest-as-promised')(Promise)

reviveDate = require './reviveDate'

wrap = (factory) ->
  out = {}
  methods.forEach (method) ->
    out[method] = ->
      test = factory[method].apply factory, arguments
      test.toPromise = ->
        self = @
        new Promise (resolve, reject) ->
          self.end (err, res) ->
            reviveDate res.body
            if err
              err.response = res
              reject err
            else
              resolve res
      test
  out

module.exports = ->
  wrap supertest.apply(null, arguments)
  
module.exports.agent = ->
  wrap supertest.agent.apply(null, arguments)
