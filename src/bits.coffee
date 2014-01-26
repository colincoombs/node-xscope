U8 = require('./u8')

# settings which are bitfields within a byte
#
class Bits extends U8

  # @property [Integer] shift - bits to shift control byte right
  #
  _shift: 0
  
  # @property [Integer] width - number of bits in the field
  _width: 1
  
  # computed mask to extract the field from the (unshifted) control byte
  #
  _mask: 0

  # lookup table for masks, given field width
  #
  @masks: [ 0x01, 0x03, 0x07, 0x0F, 0x1F, 0x3F, 0x7F, 0xFF]

  # @param [Group] parent setting group (if any)
  # @param [XScopeDriver] driver
  # @param [String] name
  # @param [Integer] index
  # @param [Integer] shift
  # @param [Integer] width
  # @param [Object] options (optional)
  #
  constructor: (parent, driver, name,
                index, @_shift, @_width, options={}) ->
    throw new Error('shift not defined') unless @_shift?
    throw new Error('width not defined') unless @_width?
    throw new Error('field overflows the byte') unless @_width + @_shift <= 8
    options.min ?= 0
    options.max ?= @constructor.masks[@_width-1]
    super(parent, driver, name, index, options)
    @_mask = @constructor.masks[@_width - 1] << @_shift

  # extract the bitfield from the byte
  #
  decode: (value) ->
    (value & @_mask) >> @_shift

  # we need to do a read-modify-write sequence to change only the bitfield
  #
  syncToHw: () ->
    byte = @_driver.readControlBytes(@_index)[0]
    #console.log 'before', byte
    byte = byte & ~@_mask
    #console.log 'masked', byte
    byte = byte | (@_value << @_shift)
    #console.log 'merged', byte
    @_driver.writeControlBytes(@_index, [ byte ])

module.exports = Bits