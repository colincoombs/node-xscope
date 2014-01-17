class Usb
  
  #
  options:
    findDevice: true
  
  #
  findByIds: (gid, vid) ->
    console.log 'findByIds', vid, gid
    if @options.findDevice
      return new Device()
    else
      return null

  #
  configure: (options) ->
    for n, v of options
      @options[n] = v

class Device

  interfaces: null
  
  constructor: () ->
    @interfaces = [ new Interface() ]

  open: () ->
    @open = true
    
  interface: (i) ->
    return @interfaces[i]
  
class Interface

  flag: 'here i am'
  
  constructor: () ->
    x = 0
  
  claim: () ->
    return
  
module.exports = new Usb()
