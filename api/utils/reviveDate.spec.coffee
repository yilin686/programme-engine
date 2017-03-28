_ = require 'lodash'
moment = require 'moment'
reviveDate = require './reviveDate'

describe 'api.utils.reviveDate', ->
  
  it '通过reviveDate处理过的数据所有时间类型字段的值应该是Date类型', ->
    originalData =
      created_at: moment().toJSON()
      
    convertedData = reviveDate originalData
    convertedData.created_at.should.be.instanceof Date
    convertedData.created_at.getTime().should.equal moment(originalData.created_at).toDate().getTime()
  
  it '传入非Object数据不应该转换', ->
    originalData = moment().toJSON()
    
    convertedData = reviveDate originalData
    convertedData.should.not.be.instanceof Date
    convertedData.should.equal originalData
  
  it '多级嵌套的时间数据应该转换成功', ->
    originalData =
      user:
        name: 'convertName'
        created_at: moment().toJSON()
    
    convertedData = reviveDate originalData
    convertedData.user.created_at.should.be.instanceof Date
    convertedData.user.created_at.getTime().should.equal moment(originalData.user.created_at).toDate().getTime()
  
  it '待转换的数据是一个数组时所有时间类型字段应该转换成功', ->
    originalData = [
        user:
          name: 'convertName1'
          created_at: moment().toJSON()
      ,
        user:
          name: 'convertName2'
          created_at: moment().add(7, 'days').toJSON()
    ]
      
    convertedData = reviveDate originalData
    convertedData[0].user.created_at.should.be.instanceof Date
    convertedData[1].user.created_at.should.be.instanceof Date
    convertedData[0].user.created_at.getTime().should.equal moment(originalData[0].user.created_at).toDate().getTime()
    convertedData[1].user.created_at.getTime().should.equal moment(originalData[1].user.created_at).toDate().getTime()
    
  it '当时间字段的值为非时间字符串应该不转换', ->
    originalData =
      created_at: '201'
  
    convertedData = reviveDate originalData
    convertedData.created_at.should.not.be.instanceof Date
    convertedData.created_at.should.equal originalData.created_at
