Setting = require('./setting')

class Bits extends Setting
  
  _byte: 0
  
  _value: 0
  
  _index: 0
  
  _shift: 0
  
  _width: 1
  
  _mask: 0
  
  _name: null
  
  @masks: [ 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF]

  constructor: (parent, driver, name,
                index, @_shift, @_width, options={}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    throw new Error('shift not defined') unless @_shift?
    throw new Error('width not defined') unless @_width?
    throw new Error('overflows the byte') unless @_width + @_shift <= 8
    @_mask = @constructor.masks[@_width - 1] << @_shift
    options.min ?= 0
    options.max ?= @constructor.masks[@_width-1]
    super(parent, driver, name, index, options)

  # @todo - parent should invoke byteToValue which we can override
  # @todo validate min/max
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    @_byte = @_driver.readControlByte(@_index) & @_mask
    value = @_byte >> @_shift
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value

  syncToHw: () ->
    byte = @_driver.readControlByte(@_index)
    byte = byte & ~@_mask
    byte = byte | @_byte
    @_driver.writeControlByte(@_index, byte)

  # @todo - push this up to superclass -ish
  # @todo validate min/max
  #
  configure: (value) ->
    if @enum
      r = -1
      r = i for n, i in @enum where n == value
      throw new Error('unknown enum value') if r < 0
    else
      @_value = value
    @_byte = @_value << @_shift
    
module.exports = Bits