events = require('events')

# Superclass for all xscope setting objects
#
# @todo describe possible options
#
class Setting extends events.EventEmitter

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
    if @enum
      @min = 0
      @max = @enum.length - 1
    if @_driver?
      @_driver.watchControlBytes(this, @_index, @_nBytes)

  # blah
  #
  name: () ->
    if @_parent?
      "#{@_parent.name()}.#{@_name}"
    else
      @_name

  # blah
  #
  metadata: () ->
    result = {}
    for field in ['min', 'max', 'enum']
      if this[field]?
        result[field] = this[field]
    return result
  
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
    @validate(value)
    if @enum
      value = @verifiedEnumValue(value)
    @updateValue(value)
  
  # fetch the current swetting from the device driver
  #
  syncFromHw: () ->
    @requireDriver()
    bytes = @_driver.readControlBytes(@_index, @_nBytes)
    value = @bytesToValue(bytes)
    value = @decode(value)
    @validate(value)
    @updateValue(value)

  # emit an event if the value actually changes
  #
  updateValue: (value) ->
    if value != @_value
      @emit 'update', @name(), value
    @_value = value
  
  # Convert control bytes into the numerical value.
  # This routine handles little-endian integer values,
  # subclasses can override it to handle other semantics.
  #
  # @return [Integer] numerical value
  #
  bytesToValue: (bytes) ->
    result = 0
    for byte in bytes.reverse()
      result = (result << 8) + byte
    return result

  # Apply any transform (shift/mask etc). By default, we do nothing.
  # Subclasses can override this.
  decode: (value) ->
    return value

  # check the value for validity
  #
  validate: (value) ->
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    
  # Install local value to driver's control data
  #
  syncToHw: () ->
    @requireDriver()
    value = @encode(@_value)
    @_driver.writeControlBytes(@_index, @valueToBytes(value))
    
    
  # Apply any transform (shift/mask etc). By default, we do nothing.
  # Subclasses can override this.
  encode: (value) ->
    value
  
  # Convert a numerical value into the control byte format.
  # This routine handles little-endian integer values,
  # subclasses can override it to handle other semantics.
  #
  valueToBytes: (value) ->
    result = []
    for i in [0...@_nBytes]
      result.push (value & 0xFF)
      value = value >> 8
    return result
  
  # @param [String] purported enumeration value
  # @return [Integer] numerical value if found
  # @throw [RangeError] if not found
  #
  verifiedEnumValue: (str) ->
    result = i for v, i in @enum when v == str
    throw new RangeError("#{@name()}: unknown value #{str}") unless result?
    return result

  requireDriver: () ->
    throw new Error('driver not present') unless @_driver?

module.exports = Setting
