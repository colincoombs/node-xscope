class Setting

  _parent: null
  
  _driver: null
  
  _name: null

  _value: null
  
  _index: null
  
  _bytes: null
  
  _nBytes: null
  
  constructor: (@_parent, @_driver, @_name, @_index, @_nBytes=1, options) ->
    throw new Error('name not defined') unless @_name?
    @_parent.add(this) if @_parent?
    for n, v of options
      @[n] = v
    @_bytes = []
    for i in [0...@_nBytes]
      @_bytes.push(0)

  name: () ->
    if @_parent?
      @_parent.name()+'.'+@_name
    else
      @_name

  value: () ->
    if @enum?
      @enum[@_value]
    else
      @_value
    
  configure: (value) ->
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    if @enum
      @_value = @verifiedEnumValue(value)
      @_min ?= 0
      @_max ?= @enum.length
    else
      @_value = value
    @valueToBytes(@_value)
  
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    for i in [0...@_nBytes]
      @_bytes[i] = @_driver.readControlByte(@_index+i)
    value = @bytesToValue()
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value
    
  syncToHw: () ->
    throw new Error('driver not present') unless @_driver?
    for i in [0...@_nBytes]
      @_driver.writeControlByte(@_index+i, @_bytes[i])
    
  valueToBytes: (value) ->
    for i in [0...@_nBytes]
      @_bytes[i] = value & 0xFF
      value = value >> 8

  bytesToValue: () ->
    result = 0
    for i in [0...@_nBytes].reverse()
      result = (result << 8) + @_bytes[i]
    return result
  
module.exports.Setting = Setting
