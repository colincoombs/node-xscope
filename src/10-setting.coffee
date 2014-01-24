# Superclass for all xscope setting objects
#
# @todo describe possible options
#
class Setting

  # @property [Group] the parent Setting object, if any
  #
  _parent: null
  
  # @property [UsbDriver] the hardware driver object (optional)
  #
  _driver: null
  
  # @property [String] the relative name of thissetting within its parent
  #
  _name: null

  # @property [Integer] the numeric value of this setting
  #
  _value: null
  
  # @property [Integer] position of this setting within the control data
  _index: null

  # @property [Integer] the number of consecutive bytes to hold this property
  #
  _nBytes: null
  
  # @property [Array<Integer>] Local copy of the control bytes
  #
  _bytes: null
  
  # @param [Group] parent  - setting object (optional)
  # @param [UsbDriver] driver - hardware driver object (optional)
  # @param [String] name - relative name of this setting
  # @param [Integer] index - offset of this setting in the device control data
  # @param [Integer] nBytes - number of bytes (1, 2, 4), default 1
  # @param [Object] options - other settings
  #
  constructor: (@_parent, @_driver, @_name, @_index, @_nBytes=1, options) ->
    throw new Error('name not defined') unless @_name?
    @_parent.add(this) if @_parent?
    for n, v of options
      @[n] = v
    @_bytes = []
    for i in [0...@_nBytes]
      @_bytes.push(0)

  # blah
  #
  name: () ->
    if @_parent?
      "#{@_parent.name()}.#{@_name}"
    else
      @_name

  # blah
  #
  value: () ->
    if @enum?
      @enum[@_value]
    else
      @_value
    
  # blah
  #
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
  
  # Copy driver's control data into instace variable.
  # Handle error checking.
  # @throw [RangeError] if illegal value
  #
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    for i in [0...@_nBytes]
      @_bytes[i] = @_driver.readControlByte(@_index+i)
    value = @bytesToValue()
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value
    
  # Install local bytes values to driver's control data
  #
  syncToHw: () ->
    throw new Error('driver not present') unless @_driver?
    for i in [0...@_nBytes]
      @_driver.writeControlByte(@_index+i, @_bytes[i])
    
  # Convert a numerical value into the control byte format.
  # This routine handles little-endian integer values,
  # subclasses can override it to handle other semantics.
  #
  valueToBytes: (value) ->
    for i in [0...@_nBytes]
      @_bytes[i] = value & 0xFF
      value = value >> 8

  # Convert control bytes into the numerical value.
  # This routine handles little-endian integer values,
  # subclasses can override it to handle other semantics.
  #
  # @return [Integer] numerical value
  #
  bytesToValue: () ->
    result = 0
    for i in [0...@_nBytes].reverse()
      result = (result << 8) + @_bytes[i]
    return result

  # @param [String] purported enumeration value
  # @return [Integer] numerical value if found
  # @throw [RangeError] if not found
  #
  verifiedEnumValue: (str) ->
    result = i for v, i in @enum when v == str
    throw new RangeError("#{@name()}: unknown value #{str}") unless result?
    return result
  
module.exports.Setting = Setting
