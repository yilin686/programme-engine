_ = require 'lodash'
mongoose = require '../../../core/mongoose'

definition =
  name:
    type: String
    required: true
    minlength: 2
    maxlength: 32

  secret:
    type: String
    required: true
    minlength: 6
    maxlength: 32

  createdAt:
    type: Date
    default: Date.now

opts = {
  versionKey: false
  toObject:
    getters: true
    transform: (doc, obj) -> _.omit obj, '_id'
  toJSON:
    getters: true
    transform: (doc, obj) -> _.omit obj, '_id'
}

schema = new mongoose.Schema(definition, opts)

module.exports = mongoose.model 'AuthClient', schema, 'oauth2_clients'
