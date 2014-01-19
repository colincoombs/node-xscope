events = require('events')

options =
  findDevice: true

class Usb
  
  #
  findByIds: (gid, vid) ->
    if options.findDevice
      return new Device()
    else
      return null

  #
  configure: (o) ->
    for n, v of o
      options[n] = v

class Device

  interfaces: null
  
  constructor: () ->
    @interfaces = [ new Interface() ]

  open: () ->
    @open = true
    
  interface: (i) ->
    return @interfaces[i]
  
  controlTransfer: (t,c,i,v,dol,cb) ->
    switch c
      when 0x61 then cb(null, new Buffer('3.14159'))
      else cb(new Error('unknown command code'), null)
        
  
class Interface

  constructor: () ->
    @endpoints =
      0x01: new OutEndpoint()
      0x81: new InEndpoint()
  
  claim: () ->
    return

  endpoint: (i) ->
    @endpoints[i]
    
class InEndpoint extends events.EventEmitter

  constructor: () ->
    x = 0

  startStream: (n, p, cb) ->
    console.log 'startStream'
    b = new Buffer(770)
    @emit 'data', b

class OutEndpoint extends events.EventEmitter

  constructor: () ->
    x = 0

module.exports = new Usb()
