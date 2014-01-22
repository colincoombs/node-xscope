# Test infrastructure
#
chai = require('chai')
should = chai.should()
expect = chai.expect

fake_usb = require('../fake/usb')

# Software under test
#
xscope = require('..')

describe 'XScope', ->
  
  describe 'constructor', ->
    
    it 'works', ->
      (-> new xscope.XScope(fake_usb)).should.not.throw(Error)
      
