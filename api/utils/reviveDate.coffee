_ = require 'lodash'

# http://www.pelagodesign.com/blog/2009/05/20/iso-8601-date-validation-that-doesnt-suck/
ISO8601 = /^([\+-]?\d{4}(?!\d{2}\b))((-?)((0[1-9]|1[0-2])(\3([12]\d|0[1-9]|3[01]))?|W([0-4]\d|5[0-2])(-?[1-7])?|(00[1-9]|0[1-9]\d|[12]\d{2}|3([0-5]\d|6[1-6])))([T\s]((([01]\d|2[0-3])((:?)[0-5]\d)?|24\:?00)([\.,]\d+(?!:))?)?(\17[0-5]\d([\.,]\d+)?)?([zZ]|([\+-])([01]\d|2[0-3]):?([0-5]\d)?)?)?)?$/

revive = (obj) ->
  if not _.isObject obj
    return obj
  if _.isArray obj
    return _.map obj, revive
    
  _.forEach obj, (value, key) ->
    if _.isObject value
      revive value
    if _.isString(value) and (3 < value.length < 27) and ISO8601.test value
      obj[key] = new Date(value)

module.exports = revive
