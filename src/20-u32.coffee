xscope = require('..')

class U32 extends xscope.Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.max ?= 0xFFFFFFFF
    options.min ?= 0
    super(parent, driver, name, index, 4, options)
    
module.exports.U32 = U32