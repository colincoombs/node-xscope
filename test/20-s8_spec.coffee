chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = {}
xscope.S8 = require('../src-cov/20-s8').S8

SOME_INDEX = 12
SOME_NAME = 'fred'
SOME_DRIVER = {}

class FakeDriver

  constructor: (@values) ->
    #console.log 'values', @values
    
  readControlByte: (index) ->
    throw new Error('wrong index') unless @values[index]?
    return @values[index]


describe 'S8', ->
  
  describe 'constructor(parent, driver, name, index)', ->

    it 'requires a driver', ->
      (->new xscope.S8(null, null, SOME_NAME, SOME_INDEX)).should.throw(Error)
      
    it 'requires a name', ->
      (-> new xscope.S8(null, SOME_DRIVER, null, SOME_INDEX)).should.throw(Error)
    
    it 'requires an index', ->
      (-> new xscope.S8(null, SOME_DRIVER, SOME_NAME, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.S8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)).should.not.throw(Error)
      
  describe 'syncFromHw()', ->
    it 'works for -128', ->
      # arrange
      # grrr - cant use SOME_INDEX here!!
      driver = new FakeDriver({7: 0x80})
      s = new xscope.S8(null,
        driver,
        SOME_NAME,
        7
      )
      # act
      s.syncFromHw()
      # assert
      s.value().should.equal(-128)
      
    it 'works for 127', ->
      # arrange
      # grrr - cant use SOME_INDEX here!!
      driver = new FakeDriver({7: 0x7F})
      s = new xscope.S8(null,
        driver,
        SOME_NAME,
        7
      )
      # act
      s.syncFromHw()
      # assert
      s.value().should.equal(127)
      
  describe 'syncToHw()', ->
    it 'has no tests yet'

  describe 'configure(value) and value()', ->
    it 'matches for 0', ->
      # arrange
      v = new xscope.S8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(0)
      # assert
      v.value().should.equal(0)

    it 'matches for 127', ->
      # arrange
      v = new xscope.S8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(127)
      # assert
      v.value().should.equal(127)

    it 'matches for -127', ->
      # arrange
      v = new xscope.S8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(-127)
      # assert
      v.value().should.equal(-127)
