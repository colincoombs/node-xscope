chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = {}
xscope.U8 = require('../src-cov/u8')

SOME_INDEX = 12
SOME_NAME = 'fred'
FakeDriver = require('../fake/driver')
SOME_DRIVER = new FakeDriver()

describe 'U8', ->
  
  describe 'constructor(parent, driver, name, index)', ->

    it 'requires a driver', ->
      (->new xscope.U8(null, null, SOME_NAME, SOME_INDEX)).should.throw(Error)
      
    it 'requires a name', ->
      (-> new xscope.U8(null, SOME_DRIVER, null, SOME_INDEX)).should.throw(Error)
    
    it 'requires an index', ->
      (-> new xscope.U8(null, SOME_DRIVER, SOME_NAME, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      #(->
      new xscope.U8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      #).should.not.throw(Error)
      
  describe 'configure(value) and value()', ->
    it 'matches for 0', ->
      # arrange
      v = new xscope.U8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(0)
      # assert
      v.value().should.equal(0)

    it 'matches for 128', ->
      # arrange
      v = new xscope.U8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(128)
      # assert
      v.value().should.equal(128)

    it 'matches for 255', ->
      # arrange
      v = new xscope.U8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)
      # act
      v.configure(255)
      # assert
      v.value().should.equal(255)

  describe 'syncFromHw()', ->
    it 'has no tests yet'

  describe 'syncToHw()', ->
    it 'has no tests yet'

