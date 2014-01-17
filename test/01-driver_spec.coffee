# Test infrastructure
#
chai = require('chai')
should = chai.should()
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
