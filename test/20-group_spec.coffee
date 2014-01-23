chai   = require('chai')
spies  = require('chai-spies')
chai.use(spies)
should = chai.should()
expect = chai.expect

xscope = {}
xscope.Group = require('../src-cov/20-group').Group
xscope.U8    = require('../src-cov/20-u8').U8

describe 'Group', ->
  
  describe 'constructor', ->
    it 'does not require a parent', ->
      (-> new xscope.Group(null, "x")).should.not.throw(Error)

    it 'does require a name', ->
      (-> new xscope.Group(null, null)).should.throw(Error)

  describe 'name()', ->
    it 'is equal to the name for parentless Items', ->
      # arrange
      item = new xscope.Group(null, 'c')
      item.name().should.equal('c')
  
    it 'is qualified by the parents name if present', ->
      # arrange
      parent = new xscope.Group(null, 'p')
      item = new xscope.Group(parent, 'c')
      item.name().should.equal('p.c')
  
  describe 'value()', ->
    it 'contains the values of each component', ->
      # arrange
      driver = {}
      g = new xscope.Group(null, 'g')
      a = new xscope.U8(g, driver, 'a', 0)
      b = new xscope.U8(g, driver, 'b', 1)
      a.configure(44)
      b.configure(55)
      # assert
      g.value().should.have.property('a', 44)
      g.value().should.have.property('b', 55)
  
  describe 'configure', ->
    it 'sets the value of each component', ->
      # arrange
      driver = {}
      g = new xscope.Group(null, 'g')
      a = new xscope.U8(g, driver, 'a', 0)
      b = new xscope.U8(g, driver, 'b', 1)
      # act
      g.configure({a: 66, b: 77})
      # assert
      a.value().should.equal(66)
      b.value().should.equal(77)
    
    it 'rejects unknown component names', ->
      # arrange
      driver = {}
      g = new xscope.Group(null, 'g')
      a = new xscope.U8(g, driver, 'a', 0)
      b = new xscope.U8(g, driver, 'b', 1)
      # assert
      (-> g.configure({a: 66, c: 88})).should.Throw(Error)
    
  describe 'syncFromHw()', ->
    it 'passes the call to each component', ->
      # arrange
      driver = { }
      g = new xscope.Group(null, 'g')
      a = new xscope.U8(g, driver, 'a', 0)
      b = new xscope.U8(g, driver, 'b', 1)
      a.syncFromHw = chai.spy()
      b.syncFromHw = chai.spy()
      # act
      g.syncFromHw()
      # assert
      a.syncFromHw.should.have.been.called
      b.syncFromHw.should.have.been.called
    
  describe 'syncToHw()', ->
    it 'passes the call to each component', ->
      # arrange
      driver = { }
      g = new xscope.Group(null, 'g')
      a = new xscope.U8(g, driver, 'a', 0)
      b = new xscope.U8(g, driver, 'b', 1)
      a.syncToHw = chai.spy()
      b.syncToHw = chai.spy()
      # act
      g.syncToHw()
      # assert
      a.syncToHw.should.have.been.called
      b.syncToHw.should.have.been.called
    
  