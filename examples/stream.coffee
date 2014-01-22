#! /usr/bin/env coffee

xscope = require('..')
stream = require('stream')
usb    = require('usb')

# just throw away the streamed data
# (useful for logging in test scenaros...?)
#
class Sink extends stream.Writable

  constructor: (options={}) ->
    # nothing extra of our own to set up
    super(options)
  
  _write: (chunk, encoding, cb) ->
    # we do nothing with the chunk of data
    # just tell the caller that we are finished with it
    console.log 'sunk', chunk.length
    cb() if cb?
    return true

# count the number of 'frames' streamed, and callback
# when the limit has been reached. Otherwise pipe the frames
# straight through.
#
class Limit extends stream.Transform

  constructor: (@limit, @limit_cb, options={}) ->
    super(options)
    @count = 0
    
  _transform: (chunk, encoding, cb) ->
    console.log 'counting', @count, @limit
    @count = @count + 1
    # pass the data on downstream
    @push(chunk)
    # tell upstream that we've handled this chunk
    cb()
    @limit_cb() if (@count >= @limit)

class Plot extends stream.Transform

  constructor:(options={}) ->
    super(options)
    @offset = 128           # pixels
    @timebase = 500.0/16.0  # us
    @gain = 1.28 / 16.0     # V
    @t = 0.0
    @frame = null
  
  _transform: (chunk, encoding, cb) ->
    console.log 'transform: frame', @frame, 'new', chunk[768]
    # accept whatever frame we get the first time
    #
    if !@frame?
      console.log 'first time'
      @frame = chunk[768]
    # if this is not the expected frame, add a gap
    # in the time access. so we will see a true (but incomplete)
    # waveform in the output
    #
    else
      @frame = @frame+1
      while ((chunk[768] - @frame) % 256) > 1
        console.log 'skipping', @frame
        @t = @t + 256 * @timebase
        @frame = @frame + 1
    console.log 'plotting', @frame
    for i in [0...256]
      # transform the output value:
      # (1) its zero coordinate is at the top
      # (2) it has the range [0..255] but covers +/- voltage
      #
      x = (255 - chunk[i] - @offset) * @gain
      
      @push(@t.toString()+' '+x.toString()+'\n')
      @t = @t + @timebase
    # add a blank line after the frame, causes gnuplot to
    # break the plot line at this point, so missed frames show
    # as true gaps in the plot.
    @push('\n')
    # tell the caller we're done with this frame
    cb()
    
driver = new xscope.XScopeDriver(usb)

limiter = new Limit(4, () ->
  console.log 'chopping'
  driver.stopStream()
)

plotter = new Plot()

limiter.pipe(plotter).pipe(process.stderr)

console.log 'opening'
driver.open()
.then( () -> console.log 'opened' )
.then(driver.start)
.then () -> 
  console.log 'startStream'
  driver.startStream(limiter) 
.then( () -> console.log 'resolved' )
.then(driver.stop)
.done()
