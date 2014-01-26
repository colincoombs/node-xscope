XScopeDriver = require('./xscopedriver')
Limit        = require('./limit')

# my fancy API class
#
class XScope extends XScopeDriver

  # @param [Object] usb - optional override for the usb interface package
  #
  constructor: (usb) ->
    usb ?= require('usb')
    super(usb)

  # blah
  #
  open: (configuration) ->
    console.log 'XScope#open', configuration
    super().then( =>
      
      @stop()

    ).then( =>

      @syncFromHw()

    ).then( =>

      if configuration?
        @settings.configure(configuration)
        @settings.syncToHw()
        @syncToHw()
    )
  
  # @param [Integer] nFrames - stop streaming after this number of frames
  #
  startStream: (nFrames, outputPipe) ->
    @limiter = new Limit(nFrames, ( => @stopStream()))
    @limiter.pipe(outputPipe)
    
    @flush().then( =>

      @start()

    ).then( =>

      super(@limiter)

    )
  
  # blah
  #
  secondsPerPixel: () ->
    @settings._value.timebase.secondsPerPixel()
  
  # blah
  #
  voltsPerPixel: (channel) ->
    switch channel
      when 1
        @settings._value.ch1._value.gain.voltsPerPixel()
      when 2
        @settings._value.ch2._value.gain.voltsPerPixel()
      else
        throw new RangeError 'channel must be 1 or 2'
  
  # blah
  #
  post: () ->
    @settings._value.trigger._value.post.value()
  
module.exports = XScope
