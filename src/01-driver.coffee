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
  
  # @property [InEndpoint] to read the captured data
  #
  rep: null
  
  # @property [OutEndpoint] to write the custom waveform
  #
  wep: null
  
  # @param [Object] usb the usb module (required)
  # @param [Integer] vid USB vendor id (optional)
  # @param [Integer} pid USB product id (optional)
  #
  constructor: (@usb, @vid=0x16D0, @pid=0x06F9) ->
    throw new Error('usb module required') unless @usb?
  
  # @return [Promise] for completion
  #
  open: () =>
    deferred = Q.defer()
    @dev = @usb.findByIds(@vid, @pid)
    if @dev
      @dev.open()
      @itf = @dev.interface(0)
      @itf.claim()
      @wep = @itf.endpoint(0x01)
      @rep = @itf.endpoint(0x81)
      deferred.resolve()
    else
      deferred.reject(new Error('device not found'))
    return deferred.promise
  
  # @param [Integer] cmd
  # @param [Integer] index
  # @param [Integer] value
  # @param [Integer | Buffer] data_or_length
  # @return [Promise] for completion and any data
  #
  controlTransfer: (cmd, index=0, value=0, data_or_length=0) =>
    deferred = Q.defer()
    if @dev
      @dev.controlTransfer(0xC0, cmd, index, 0, 4, (err, data) ->
        if (err)
          deferred.reject(err)
        else
          deferred.resolve(data)
      )
    else
      deferred.reject(new Error('device not open'))
    return deferred.promise

  # @param [Integer] length
  # @return [Promise] for the data
  #
  read: (length=770) =>
    deferred = Q.defer()
    if @dev
      @rep.transfer(length, (err, data) ->
        if (err)
          deferred.reject(err)
        else
          deferred.resolve(data)
      )
    else
      deferred.reject(new Error('device not open'))
    return deferred.promise
    
  # @param [Buffer] data to write
  # @return [Promise] for completion
  #
  write: (data) =>
    deferred = Q.defer()
    if @dev
      @wep.transfer(data, (err, data) ->
        if (err)
          deferred.reject(err)
        else
          deferred.resolve(data)
      )
    else
      deferred.reject(new Error('device not open'))
    return deferred.promise
    
  # @param [Integer] length to try reading
  # @return [Promise] for completion
  # @todo limit to 2 reads, then reejct the promise!
  #
  flush: (length=770) =>
    deferred = Q.defer()
    @read(length).then( () ->
      @flush()
    , deferred.resolve()
    )
    return deferred.promise
    
    
    
  # @param [WriteStream]
  # @return [Promise]
  #
  startStream: (@writeStream) ->
    @streaming = Q.defer()
    if !@writeStream?
      @streaming.reject(new Error('writeStream required'))
    else if !@dev?
      @streaming.reject(new Error('device not open'))
    else
      @rep = @itf.endpoint(0x81)
      @rep.on 'data', @streamData
      @rep.on 'error', @streamError
      @rep.on 'end', @streamEnd
      @rep.startStream(3, 770)
    return @streaming.promise
        
  stopStream: () ->
    @rep.stopStream() if @dev?
    @streaming.resolve()

  streamData: (data) =>
    console.log 'data', data.length
    @writeStream.write(data)
    
  streamError: (err) =>
    console.log err
    console.error err
    
  streamEnd: () =>
    console.log 'end'
    @writeStream.end()
  
  # @return [Promise] for the firmware version as a string.
  #
  getFirmwareVersion: () =>
    @controlTransfer(0x61, 0, 0, 4)
    .then( (data) ->
      data.toString()
    )
    
  stop: () =>
    @controlTransfer(0x66)

  start: () =>
    @controlTransfer(0x67)

module.exports.Driver = Driver
