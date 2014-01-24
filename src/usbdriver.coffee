Q = require('q')

# my simplified USB driver class
#
class UsbDriver

  # @property [Device] the usb-module device
  # @private
  #
  __dev: null
  
  # @property [Interface] the usb-module interface
  # @private
  #
  __itf: null
  
  # @property [InEndpoint] to read the captured data
  # @private
  __rep: null
  
  # @property [OutEndpoint] to write the custom waveform
  # @private
  #
  __wep: null
  
  # @property [WriteStream] for srtreaming reads.
  # @private
  __writeStream: null
  
  # @property [Array<Integer>] to hold the scope's control data
  # @protected
  #
  _controlBytes: null
    
  # @param [Object] usb the usb module (required)
  # @param [Integer] vid USB vendor id (optional)
  # @param [Integer} pid USB product id (optional)
  #
  constructor: (@usb, @vid=0x16D0, @pid=0x06F9) ->
    throw new Error('usb module required') unless @usb?
    @_controlBytes = []
    for i in [0...44]
      @_controlBytes[i] = 0
    
  # @return [Promise] for completion
  #
  open: () =>
    deferred = Q.defer()
    @__dev = @usb.findByIds(@vid, @pid)
    if @__dev
      @__dev.open()
      @__itf = @__dev.interface(0)
      @__itf.claim()
      @__wep = @__itf.endpoint(0x01)
      @__rep = @__itf.endpoint(0x81)
      deferred.resolve()
    else
      deferred.reject(new Error('device not found'))
    return deferred.promise
  
  close: () ->
    deferred = Q.defer()
    if @__dev
      @__itf.release( (err) =>
        if err
          deferred.reject(err)
        else
          @__dev.close()
          deferred.resolve()
      )
    else
      deferred.reject(new Error('device not open'))
    return deferred.promise

  # @param [Integer] cmd
  # @param [Integer] index
  # @param [Integer] value
  # @param [Integer | Buffer] data_or_length
  # @return [Promise] for completion and any data
  # @protected
  #
  _controlTransfer: (cmd, index=0, value=0, data_or_length=0) =>
    #console.log 'controlTransfer', cmd, index, value, data_or_length
    deferred = Q.defer()
    if @__dev
      @__dev.controlTransfer(0xC0, cmd, index, 0, data_or_length, (err, data) ->
        if (err)
          console.log 'oops', err
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
    if @__dev
      @__rep.transfer(length, (err, data) ->
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
    if @__dev
      @__wep.transfer(data, (err, data) ->
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
    
    
    
  # @param [WriteStream] writeStream
  # @return [Promise]
  #
  startStream: (@__writeStream) =>
    @streaming = Q.defer()
    if !@__writeStream?
      @streaming.reject(new Error('writeStream required'))
    else if !@__dev?
      @streaming.reject(new Error('device not open'))
    else
      @__rep = @__itf.endpoint(0x81)
      @__rep.on 'data',  @__streamData
      @__rep.on 'error', @__streamError
      @__rep.on 'end',   @__streamEnd
      @__rep.startStream(3, 1500)
    return @streaming.promise
        
  stopStream: () =>
    @__rep.stopStream() if @__dev?
    @streaming.resolve()

  __streamData: (data) =>
    @__writeStream.write(data)
    
  __streamError: (err) =>
    @streaming.reject(err)
    
  __streamEnd: () =>
    @__writeStream.end()
    
module.exports = UsbDriver
