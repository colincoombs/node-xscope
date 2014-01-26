chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = {}
xscope.Bits = require('../src-cov/bits')

SOME_WIDTH = 2
SOME_OFFSET = 3
SOME_INDEX = 12
SOME_NAME = 'fred'

FakeDriver = require('../fake/driver')

SOME_DRIVER = new FakeDriver

describe 'Bits', ->
  
  describe 'constructor(parent, driver, name, index, offset, width)', ->

    it 'requires a driver', ->
      (->new xscope.Bits(null, null, SOME_NAME, SOME_INDEX, SOME_OFFSET, SOME_WIDTH)).should.throw(Error)
      
    it 'requires a name', ->
      (-> new xscope.Bits(null, SOME_DRIVER, null, SOME_INDEX, SOME_OFFSET, SOME_WIDTH)).should.throw(Error)
    
    it 'requires an index', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, null, SOME_OFFSET, SOME_WIDTH)).should.throw(Error)
    
    it 'requires an offset', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, SOME_INDEX, null, SOME_WIDTH)).should.throw(Error)
    
    it 'requires an width', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, SOME_INDEX, SOME_OFFSET, null)).should.throw(Error)
    
    it 'must fit within the byte', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, SOME_INDEX, 4, 5)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, SOME_INDEX, SOME_OFFSET, SOME_WIDTH)).should.not.throw(Error)
      
  describe 'syncFromHw()', ->
    it 'works', ->
      #arrange
      driver = new FakeDriver( 12: 0xFF )
      bits   = new xscope.Bits(null, driver, SOME_NAME, SOME_INDEX,
        4,
        3)
      #act
      bits.syncFromHw()
      #assert
      bits.value().should.equal(7)

  describe 'syncToHw()', ->
    it 'works', ->
      driver = new FakeDriver( 12: 0xCF )
      bits   = new xscope.Bits(null, driver, SOME_NAME, SOME_INDEX,
        4,
        3)
      #act
      bits.configure(5)
      bits.syncToHw()
      #assert
      driver.values[12].should.equal(0xDF)

  describe 'value()', ->
    it 'has no tests yet'

  describe 'name()', ->
    it 'has no tests yet'

  describe 'comfigure(value)', ->
    it 'has no tests yet'

