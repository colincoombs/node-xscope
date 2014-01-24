Setting = require('./setting')

class U8 extends Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.min ?= 0
    options.max ?= 255
    super(parent, driver, name, index, 1, options)
    
module.exports = U8