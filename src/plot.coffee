stream = require('stream')

class Plot extends stream.Transform

  constructor:(@timebase, @gain, @before, options={}) ->
    super(options)
    @offset = 128           # pixels
    @t = (@before * @timebase)
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
    
module.exports = Plot
