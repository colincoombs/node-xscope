Q = require('q')

# my simplified USB driver class
#
class Driver

  # @property [Device] the usb-module device
  #
  dev: null
  
  # @property [Interface] the usb-module interface
  #
  itf: null
  
  # @param [Object] usb the usb module (required)
  # @param [Integer] vid USB vendor id (optional)
  # @param [Integer} pid USB product id (optional)
  #
  constructor: (@usb, @vid=0x16D0, @pid=0x06F9) ->
    throw new Error('usb module required') unless @usb?
  
  # @return [Promise] for completion
  #
  open: () ->
    deferred = Q.defer()
    @dev = @usb.findByIds(@vid, @gid)
    if @dev
      @itf = @dev.interfaces[0]
      @itf.claim()
      deferred.resolve()
    else
      deferred.reject(new Error('device not found'))
    return deferred.promise
  
module.exports.Driver = Driver
