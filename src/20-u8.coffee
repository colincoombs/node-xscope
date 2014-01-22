xscope = require('..')

class U8 extends xscope.Setting

  _byte: 0
  
  constructor: (parent, driver, name, index, options) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    super(parent, driver, name, index, options)
    @min ?= 0
    @max ?= 255
    
  configure: (value) ->
    @_value = value
    @_byte = @_value
    
module.exports.U8 = U8