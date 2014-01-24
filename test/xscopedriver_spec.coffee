# Test infrastructure
#
chai = require('chai')
should = chai.should()
expect = chai.expect

fake_usb = require('../fake/usb')

# Software under test
#
xscope = {}
xscope.XScopeDriver = require('../src-cov/xscopedriver')

describe 'XScopeDriver', ->
  
  describe 'constructor', ->
    
    it 'requires a usb package', ->
      (-> new xscope.XScopeDriver).should.throw('usb module required')

    it 'is happy with a fake usb module', ->
      #(->
      new xscope.XScopeDriver(fake_usb)
      #).should.not.throw(Error)
      
  describe 'getFirmwareVersion()', ->
    
    it 'is rejected unless the device has been opened', (done) ->
      
      # arrange
      fake_usb.configure { findDevice: true }
      driver = new xscope.XScopeDriver(fake_usb)
      
      # act
      promise = driver.getFirmwareVersion()
      
      # assert
      promise.then(
        ()    -> done(new Error('should not happen'))
      , (err) -> done()
      )
      
    it 'returns a string', (done) ->

      # arrange
      fake_usb.configure { findDevice: true }
      driver = new xscope.XScopeDriver(fake_usb)
      
      # act
      promise = driver.open()
        .then( driver.getFirmwareVersion )
        
      # assert
      promise.then( (v) ->
        v.should.be.a('string')
      ).then(
        ()    -> done()
      , (err) -> done(err)
      )

  describe 'start()', ->
    it 'has no tests yet'
    
  describe 'stop()', ->
    it 'has no tests yet'
  
  describe 'syncFromHw()', ->
    it 'has no tests yet'
  
  describe 'readControlByte(index)', ->
    it 'has no tests yet'
  
  describe 'writeControlByte(index, value)', ->
    it 'has no tests yet'
  
