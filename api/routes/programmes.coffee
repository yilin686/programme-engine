_ = require 'lodash'
moment = require 'moment'
express = require '../express'
validate = require '../../utils/validate'
Errors = require '../errors'
Programme = require '../../core/models/programme'
Promise = require 'bluebird'

client = require('../../utils/nodeRestClientPromise').Client({})

module.exports = router = express.Router()

###
  @api {GET} /programmes 获取目标频率当前时间下`节目单`
  @apiGroup Programmes
  @apiParam {ObjectId} channel
  @apiParam {Date} from
  @apiParam {Number} duration
  @apiSuccessExample {json} Body
    {
    }
###
router.get '/', (req, res, next) ->
  channelId = req.query.channel
  hour = moment().format('H')

  Promise
    .all [
      client.getPromise("http://localhost:3100/open_api/programme_rules?channel=#{channelId}").then (result) -> result.data
      Programme.findOrCreate(channelId, moment(moment().format('YYYY-MM-DD')))
    ]
    .then ([programmeRule, programme]) ->
      if programme.clocks[hour].items?.length > 0
        res.json programme
      else
        clockPieces = programmeRule.programmeClocks[hour].pieces
        pieceGroups = _.groupBy clockPieces, 'programmeSelector'
        programmeSelectorIds = _.pluck(clockPieces, 'programmeSelector')
        Promise.all [
          client.getPromise("http://localhost:3100/open_api/programme_selectors?ids=#{JSON.stringify(programmeSelectorIds)}").then (result) -> result.data
          client.getPromise("http://localhost:3100/open_api/entry_field_definitions").then (result) -> result.data
        ]
        .then ([programmeSelectors, audioFieldIds]) ->
          Promise.props(
            # 按programmeSelector分组查询
            _.mapValues pieceGroups, (pieces, programmeSelectorId) ->
              programmeSelector = _.find programmeSelectors, id: programmeSelectorId
              count = _(pieces).pluck('count').reduce (total, n) -> total + n
              client.getPromise("http://localhost:3100/open_api/entries/search?ids=#{JSON.stringify(programmeSelector.entries)}&collections=#{JSON.stringify(programmeSelector.collections)}&attributes=#{JSON.stringify(programmeSelector.attributes)}&libraries=#{JSON.stringify(programmeSelector.libraries)}&entryTypes=#{JSON.stringify(programmeSelector.entryTypes)}&selectBy=#{programmeSelector.selectBy}&limit=#{count}").then (result) -> result.data
          )
          .then (entryGroups) ->
            _.mapValues entryGroups, (entries) ->
              _(entries).flatten().map((entry) ->
                audioField = _.find(entry.fields, (field) -> _.any(audioFieldIds, (id) -> id.equals field.definition))
                if audioField?.value?.fileId
                  title: entry.title
                  audio: audioField.value
                  entry: entry._id
                else
                  null
              ).compact().value()
          .then (itemGroups) ->
            items = _(for piece in clockPieces
              items = _.take itemGroups[piece.programmeSelector], piece.count
              itemGroups[piece.programmeSelector] = _.drop itemGroups[piece.programmeSelector], piece.count
              items
            ).flatten().compact().value()
            Programme.updateOfClocks(channelId, moment(moment().format('YYYY-MM-DD')), hour, items)
              .then (programme) ->
                console.log programme
                res.json programme