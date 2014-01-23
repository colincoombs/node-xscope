Setting = require('./10-setting').Setting

class U32 extends Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.max ?= 0xFFFFFFFF
    options.min ?= 0
    super(parent, driver, name, index, 4, options)
    
module.exports.U32 = U32