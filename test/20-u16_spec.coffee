chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = require('..')

SOME_INDEX = 12
SOME_NAME = 'fred'
SOME_DRIVER = {}

class FakeDriver

  constructor: (@values) ->
    #console.log 'values', @values
    
  readControlByte: (index) ->
    throw new Error('wrong index') unless @values[index]?
    return @values[index]



describe 'U16', ->
  
  describe 'constructor(parent, driver, name, index)', ->

    it 'requires a driver', ->
      (->new xscope.U16(null, null, SOME_NAME, SOME_INDEX)).should.throw(Error)
      
    it 'requires a name', ->
      (-> new xscope.U16(null, SOME_DRIVER, null, SOME_INDEX)).should.throw(Error)
    
    it 'requires an index', ->
      (-> new xscope.U16(null, SOME_DRIVER, SOME_NAME, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.U16(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)).should.not.throw(Error)
      
  describe 'syncFromHw()', ->
    it 'ummm', ->
      # arrange
      # grrr - cant use SOME_INDEX here!!
      driver = new FakeDriver({7: 0x34, 8: 0x12})
      s = new xscope.U16(null,
        driver,
        SOME_NAME,
        7
      )
      # act
      s.syncFromHw()
      # assert
      s.value().should.equal(0x1234)
      
  describe 'syncToHw()', ->
    it 'has no tests yet'

  describe 'configure(value) and value()', ->
    it 'matches for 0', ->
      # arrange
      v = new xscope.U16(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(0)
      # assert
      v.value().should.equal(0)

    it 'matches for 0x1234', ->
      # arrange
      v = new xscope.U16(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(0x1234)
      # assert
      v.value().should.equal(0x1234)

    it 'matches for 0xFFFF', ->
      # arrange
      v = new xscope.U16(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(0xFFFF)
      # assert
      v.value().should.equal(0xFFFF)
