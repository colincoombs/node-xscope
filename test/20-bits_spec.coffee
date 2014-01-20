chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = require('..')

SOME_WIDTH = 2
SOME_OFFSET = 3
SOME_INDEX = 12
SOME_NAME = 'fred'
SOME_DRIVER = {}

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
    
    it 'works, otherwise', ->
      (-> new xscope.Bits(null, SOME_DRIVER, SOME_NAME, SOME_INDEX, SOME_OFFSET, SOME_WIDTH)).should.not.throw(Error)
      
  describe 'syncFromHw()', ->
    it 'has no tests yet'

  describe 'syncToHw()', ->
    it 'has no tests yet'

  describe 'value()', ->
    it 'has no tests yet'

  describe 'name()', ->
    it 'has no tests yet'

  describe 'comfigure(value)', ->
    it 'has no tests yet'

