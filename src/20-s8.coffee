xscope = require('..')

class S8 extends xscope.Setting

  _byte: 0
  
  constructor: (parent, driver, name, index, options) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    super(parent, driver, name, index, options)
    @min ?= -128
    @max ?= 127
    
  configure: (value) ->
    @_value = value
    @_byte = @_value % 256
    
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    @_byte = @_driver.readControlByte(@_index)
    value = @_byte
    value = value - 256 if value > 127
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value

module.exports.S8 = S8