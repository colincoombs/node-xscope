# Test infrastructure
#
chai = require('chai')
should = chai.should()
expect = chai.expect

fake_usb = require('../fake/usb')

# Software under test
#
xscope = {}
xscope.XScope = require('../src-cov/20-xscope').XScope

describe 'XScope', ->
  
  describe 'constructor', ->
    
    it 'works', ->
      (-> new xscope.XScope(fake_usb)).should.not.throw(Error)
      
