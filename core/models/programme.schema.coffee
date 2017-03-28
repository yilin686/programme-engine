_ = require 'lodash'
mongoose = require '../mongoose'

itemSchema = new mongoose.Schema(
  title:
    type: String

  audio:
    fileId:
      type: String

    size:
      type: Number

    name:
      type: String

    uniqueIdentifier:
      type: String

  entry:
    type: mongoose.Schema.Types.ObjectId

, {id: false})

definition =
  channel:
    type: mongoose.Schema.Types.ObjectId
    required: true
    index: true

  date:
    type: Date
    required: true
    index: true

  rule:
    type: mongoose.Schema.Types.ObjectId

  clocks:
    type: [
      new mongoose.Schema(
        items: [itemSchema]
      , _id: false, id: false)
    ]
    required: true

  __deleted:
    type: Boolean
    required: true
    default: false

opts =
  versionKey: false
  toObject:
    getters: true
    transform: (doc, obj) -> _.omit obj, '_id'
  toJSON:
    getters: true
    transform: (doc, obj) -> _.omit obj, '_id'

schema = new mongoose.Schema(definition, opts)

module.exports = schema
