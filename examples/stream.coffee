#! /usr/bin/env coffee

xscope = require('..')
stream = require('stream')
usb    = require('usb')
#os     = require('os')
#fs     = require('fs')

class Plot extends stream.Transform

  constructor:(options={}) ->
    super(options)
    @offset = 128           # pixels
    @timebase = 500.0/16.0  # us
    @gain = 1.28 / 16.0     # V
    @t = 0.0
    @frame = null
  
  _transform: (chunk, encoding, cb) ->
    # accept whatever frame we get the first time
    #
    if !@frame?
      @frame = chunk[768]
    # if this is not the expected frame, add a gap
    # in the time axis. so we will see a true (but incomplete)
    # waveform in the output
    #
    else
      @frame = @frame+1
      while ((chunk[768] - @frame) % 256) > 1
        @t = @t + 256 * @timebase
        @frame = @frame + 1
    for i in [0...256]
      # transform the output value:
      # (1) its zero coordinate is at the top
      # (2) it has the range [0..255] but covers +/- voltage
      #
      x = (255 - chunk[i] - @offset) * @gain
      
      @push("#{@t} #{x}\n")
      @t = @t + @timebase
    # add a blank line after the frame, causes gnuplot to
    # break the plot line at this point, so missed frames show
    # as true gaps in the plot.
    @push('\n')
    # tell the caller we're done with this frame
    cb()
    
scope = new xscope.XScope(usb)

limiter = new xscope.Limit()
limiter.then( =>
  scope.stopStream()
)

limiter
  .pipe(new Plot())
  .pipe(new xscope.Gnuplot())

scope.open().then( =>
  scope.start()
).then () -> 
  scope.startStream(limiter) 
.then( =>
  scope.stop()
).done()
