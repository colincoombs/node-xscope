class Usb
  
  #
  options:
    findDevice: true
  
  #
  findByIds: () ->
    if @options.findDevice
      return new Device()
    else
      return null

  #
  configure: (options) ->
    for n, v of options
      @options[n] = v

class Device

  constructor: () ->
    @interfaces = [ new Interface() ]

class Interface

  constructor: () ->
    x = 0
  
  claim: () ->
    return
  
module.exports = new Usb()
