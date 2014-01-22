class Setting

  _parent: null
  
  _driver: null
  
  _name: null

  _value: null
  
  _index: null
  
  constructor: (@_parent, @_driver, @_name, @_index, options) ->
    throw new Error('name not defined') unless @_name?
    #console.log 'addme', this
    @_parent.add(this) if @_parent?
    for n, v of options
      @[n] = v

  name: () ->
    if @_parent?
      @_parent.name()+'.'+@_name
    else
      @_name

  configure: (value) ->
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    if @enum
      @_value = @verifiedEnumValue(value)
      @_min ?= 0
      @_max ?= @enum.length
    else
      @_value = value
    @_byte = @_value << @_shift
    
  verifiedEnumValue: (str) ->
    r = -1
    r = i for n, i in @enum when n == str
    if r < 0
      throw new RangeError("#{@name()}: unknown value '#{str}'")
    
  value: () ->
    if @enum?
      @enum[@_value]
    else
      @_value
    
  syncFromHw: () ->
    throw new Error('driver not present') unless @_driver?
    @_byte = @_driver.readControlByte(@_index)
    value = @_byte
    if (@min? and value < @min) or (@max? and value > @max)
      throw new RangeError("#{@name()}: value out of range: '#{value}'")
    @_value = value
    
  syncToHw: () ->
    throw new Error('driver not present') unless @_driver?
    @_driver.writeControlByte(@_index, @_byte)
    

module.exports.Setting = Setting
