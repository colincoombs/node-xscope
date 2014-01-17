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
