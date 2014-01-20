chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = require('..')

SOME_NAME = 'fred'
SOME_DRIVER = {}

describe 'Setting', ->
  
  describe 'constructor(parent, driver, name, options)', ->

    it 'requires a name', ->
      (-> new xscope.Setting(null, SOME_DRIVER, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.Setting(null, SOME_DRIVER, SOME_NAME)).should.not.throw(Error)
   
    it 'can be given options', ->
      # arrange
      # act
      s = new xscope.Setting(null,
        SOME_DRIVER,
        SOME_NAME,
        max: 21,
        min: 1
      )
      # assert
      s.should.have.property('max', 21)
      s.should.have.property('min',1)
    
  describe 'name()', ->
    
    it 'is equal to the name for a parentless Setting', ->
      # arrange
      item = new xscope.Setting(null, SOME_DRIVER, 'c')
      # act
      result = item.name()
      # assert
      result.should.equal('c')
  
    it 'is qualified by the parents name if present', ->
      # arrange
      parent = new xscope.Group(null, 'p')
      item = new xscope.Setting(parent, SOME_DRIVER, 'c')
      # act
      result =item.name()
      # assert
      result.should.equal('p.c')
  
  describe 'configure(value)', ->
    it 'rejects values which are too small', ->
      # arrange
      s = new xscope.Setting(
        null,
        SOME_DRIVER,
        SOME_NAME,
        max: 21,
        min: 1
      )      
      # act/assert
      (-> s.configure(0)).should.throw(RangeError)

    it 'rejects values which are too large', ->
      # arrange
      s = new xscope.Setting(
        null,
        SOME_DRIVER,
        SOME_NAME,
        max: 21,
        min: 1
      )      
      # act/assert
      (-> s.configure(22)).should.throw(RangeError)

    it 'rejects unknown enumeration values', ->
      # arrange
      s = new xscope.Setting(
        null,
        SOME_DRIVER,
        SOME_NAME,
        enum: [
          'red',
          'green',
          'blue'
        ]
      )      
      # act/assert
      (-> s.configure('pink')).should.throw(RangeError)

    it 'accepts known enumeration values', ->
      # arrange
      s = new xscope.Setting(
        null,
        SOME_DRIVER,
        SOME_NAME,
        enum: [
          'red',
          'green',
          'blue'
        ]
      )      
      # act/assert
      (-> s.configure('green')).should.not.throw(RangeError)

  describe 'value()', ->
    it 'has no tests yet'


  describe 'syncFromHw()', ->
    it 'has no tests yet'

  describe 'syncToHw()', ->
    it 'has no tests yet'

