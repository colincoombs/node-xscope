chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = require('..')

SOME_INDEX = 12
SOME_NAME = 'fred'
SOME_DRIVER = {}

describe 'U8', ->
  
  describe 'constructor(parent, driver, name, index)', ->

    it 'requires a driver', ->
      (->new xscope.U8(null, null, SOME_NAME, SOME_INDEX)).should.throw(Error)
      
    it 'requires a name', ->
      (-> new xscope.U8(null, SOME_DRIVER, null, SOME_INDEX)).should.throw(Error)
    
    it 'requires an index', ->
      (-> new xscope.U8(null, SOME_DRIVER, SOME_NAME, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.U8(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)).should.not.throw(Error)
      
  describe 'syncFromHw()', ->
    it 'has no tests yet'

  describe 'syncToHw()', ->
    it 'has no tests yet'

  describe 'value()', ->
    it 'has no tests yet'

  describe 'comfigure(value)', ->
    it 'has no tests yet'

