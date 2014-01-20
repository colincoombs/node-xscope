xscope = require('..')

class U8 extends xscope.Setting

  _byte: 0
  
  _index: 0
  
  constructor: (parent, driver, name, @_index, options) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless @_index?
    super(parent, driver, name, options)
    
  configure: (value) ->
    @_value = value
    @_byte = @_value
    
module.exports.U8 = U8