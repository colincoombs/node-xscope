Setting = require('./10-setting').Setting

class U16 extends Setting

  constructor: (parent, driver, name, index, options = {}) ->
    throw new Error('driver not defined') unless driver?
    throw new Error('index not defined') unless index?
    options.max ?= 65535
    options.min ?= 0
    super(parent, driver, name, index, 2, options)
    
module.exports.U16 = U16