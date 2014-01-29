chai = require('chai')
should = chai.should()
expect = chai.expect

xscope = {}
xscope.Setting = require('../src-cov/setting')
xscope.Group   = require('../src-cov/group')
xscope.U8      = require('../src-cov/u8')

SOME_NAME = 'fred'
SOME_DRIVER = {}
SOME_INDEX = 7
NUMBER_OF_BYTES = 2
SOME_VALUE = 83

FakeDriver = require('../fake/driver')
SOME_DRIVER = new FakeDriver()


describe 'Setting', ->
  
  describe 'constructor(parent, driver, name, index, options)', ->

    it 'requires a name', ->
      (-> new xscope.Setting(null, SOME_DRIVER, null, null)).should.throw(Error)
    
    it 'works, otherwise', ->
      (-> new xscope.Setting(null, SOME_DRIVER, SOME_NAME, SOME_INDEX)).should.not.throw(Error)
   
    it 'can be given options', ->
      # arrange
      # act
      s = new xscope.Setting(null,
        SOME_DRIVER,
        SOME_NAME,
        SOME_INDEX,
        NUMBER_OF_BYTES,
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
        SOME_INDEX,
        NUMBER_OF_BYTES,
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
        SOME_INDEX,
        NUMBER_OF_BYTES,
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
        SOME_INDEX,
        NUMBER_OF_BYTES,
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
        SOME_INDEX,
        NUMBER_OF_BYTES,
        enum: [
          'red',
          'green',
          'blue'
        ]
      )      
      # act/assert
      (-> s.configure('green')).should.not.throw(RangeError)

  describe 'value()', ->
    it 'shows the value', ->
      # arrange
      s = new xscope.Setting(
        null,
        SOME_DRIVER,
        SOME_NAME,
        SOME_INDEX,
        NUMBER_OF_BYTES,
        enum: [
          'red',
          'green',
          'blue'
        ]
      )
      # act
      s.configure('blue')
      # assert
      s.value().should.equal('blue')

  describe 'metadata()', ->
    it 'does numerics', ->
      # arrange
      s = new xscope.U8(
        null,
        SOME_DRIVER,
        SOME_NAME,
        SOME_INDEX
      )
      # act, # assert
      s.metadata().should.deep.equal({min: 0, max: 255})

    it 'does enums', ->
      # arrange
      s = new xscope.U8(
        null,
        SOME_DRIVER,
        SOME_NAME,
        SOME_INDEX,
        enum: [
          'black',
          'white'
        ]
      )
      # act, # assert
      s.metadata().should.deep.equal({
        min: 0,
        max: 1,
        enum: ['black','white']
      })

  describe 'syncFromHw()', ->
    it 'ummm', ->
      # arrange
      # grrr - cant use SOME_INDEX here!!
      driver = new FakeDriver({7: SOME_VALUE})
      s = new xscope.Setting(null,
        driver,
        SOME_NAME,
        7
      )
      # act
      s.syncFromHw()
      # assert
      s.value().should.equal(SOME_VALUE)
      
  describe 'syncToHw()', ->
    it 'works', ->
      # arrange
      # grrr - cant use SOME_INDEX here!!
      driver = new FakeDriver({7: SOME_VALUE})
      s = new xscope.Setting(null,
        driver,
        SOME_NAME,
        7
      )
      # act
      s.syncToHw()
      # assert
      #s.value().should.equal(SOME_VALUE)

