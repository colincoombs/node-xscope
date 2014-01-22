xscope = require('..')

class U16 extends xscope.Setting

  _bytes: [0, 0]
  
  constructor: (parent, driver, name, index, options) ->
    super(parent, driver, name, index, options)
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    @max ?= 65535
    @min ?= 0
    
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    for i in [0...2]
      @_bytes[i] = @_driver.readControlByte(@_index + i)
    value = @_bytes[0] * 256 + @_bytes[1]
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value


  configure: (value) ->
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    if @enum
      @_value = @verifiedEnumValue(value)
    else
      @_value = value
    @_bytes[0] = @_value & 0xFF
    @_bytes[1] = (@_value >> 8) & 0xFF
    
    
  syncToHw: () ->
    for i in [0...2]
      @_driver.writeControlByte(@_index+i, @_bytes[i])
    

module.exports.U16 = U16