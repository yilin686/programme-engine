_ = require 'lodash'
mongoose = require '../../../core/mongoose'

definition =
  userId:
    type: mongoose.Schema.Types.ObjectId
    required: true

  clientId:
    type: mongoose.Schema.Types.ObjectId
    required: true

  accessToken:
    type: String
    required: true
    unique: true
    index: true

  refreshToken:
    type: String
    required: true
    unique: true
    index: true

  createdAt:
    type: Date
    default: Date.now

opts = {
  versionKey: false
  toObject:
    transform: (doc, obj) -> _.omit obj, '_id'
  toJSON:
    transform: (doc, obj) -> _.omit obj, '_id'
}

schema = new mongoose.Schema(definition, opts)

module.exports = mongoose.model 'AuthToken', schema, 'oauth2_tokens'
