Setting = require('./setting')

class S8 extends Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.min ?= -128
    options.max ?= 127
    super(parent, driver, name, index, 1, options)

  decode: (value) ->
    if value > 127
      value - 256
    else
      value
    
  encode: (value) ->
    value % 256
    
module.exports = S8