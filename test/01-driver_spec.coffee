# Test infrastructure
#
chai = require('chai')
should = chai.should()
expect = chai.expect

fake_usb = require('../fake/usb')

# Software under test
#
xscope = require('..')

describe 'Driver', ->
  
  describe 'constructor', ->
    
    it 'requires a usb package', ->
      (-> new xscope.Driver).should.throw('usb module required')

    it 'is happy with a fake usb module', ->
      (-> new xscope.Driver(fake_usb)).should.not.throw(Error)
      
  describe 'open()', ->
    
    it '[returns a promise which] is resolved on success', (done) ->
      # arrange
      fake_usb.configure { findDevice: true }
      driver = new xscope.Driver(fake_usb)
      
      # act
      promise = driver.open()
      
      # assert
      promise.then(
        ()    -> done()
      , (err) -> done(err)
      )
      
    it '[returns a promise which] is rejected on failure', (done) ->
      # arrange
      fake_usb.configure { findDevice: false }
      driver = new xscope.Driver(fake_usb)
      
      # act
      promise = driver.open()
      
      # assert
      promise.then(
        ()    -> done(new Error('should be rejected'))
      , (err) -> done()
      )

  describe 'close()', ->
    it 'is not written yet!'
    
  describe 'controlTransfer()', ->
    it 'has no tests yet'
  
  describe 'read()', ->
    it 'has no tests yet'
    
  describe 'write()', ->
    it 'has no tests yet'
    
  describe 'flush()', ->
    it 'has no tests yet'
    
  describe 'startStream()', ->
    it 'has no tests yet'
    
  describe 'stopStream()', ->
    it 'has no tests yet'
  
  describe 'streamData()', ->
    it 'has no tests yet'
    
  describe 'streamError()', ->
    it 'has no tests yet'
    
  describe 'streamEnd()', ->
    it 'has no tests yet'
    
  describe 'getFirmwareVersion()', ->
    
    it 'is rejected unless the device has been opened', (done) ->
      
      # arrange
      fake_usb.configure { findDevice: true }
      driver = new xscope.Driver(fake_usb)
      
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
      driver = new xscope.Driver(fake_usb)
      
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
  
