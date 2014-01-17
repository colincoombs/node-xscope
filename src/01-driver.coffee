# my simplified USB driver class
#
class Driver

  # @param [Object] usb the usb module (required)
  #
  constructor: (@usb) ->
    throw new Error('usb module required') unless @usb?
  
module.exports.Driver = Driver
