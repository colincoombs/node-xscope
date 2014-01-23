Setting = require('./10-setting').Setting

class S8 extends Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.min ?= -128
    options.max ?= 127
    super(parent, driver, name, index, 1, options)
    
  valueToBytes: (value) ->
    super(value % 256)
    #@_bytes[0] = @_bytes[0] % 256
    
  bytesToValue: () ->
    result = super()
    result = result - 256 if result > 127
    return result

module.exports.S8 = S8