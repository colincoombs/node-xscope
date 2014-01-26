stream = require('stream')

class Plot extends stream.Transform

  constructor:(@timebase, @gain, @before, options={}) ->
    super(options)
    @offset = 128         # pixels
    @t = (@before * @timebase)
    @delta = 10
    @stride = 20
    @frame = null
  
  _transform: (chunk, encoding, cb) ->
    # accept whatever frame we get the first time
    #
    if !@frame?
      @frame = chunk[768]
    else
      @frame = @frame+1
      while ((chunk[768] - @frame) % 256) > 1
        # if this is not the expected frame, add a gap
        # in the time axis. so we will see a true (but incomplete)
        # waveform in the output
        #
        @t = @t + 256 * @timebase
        @frame = @frame + 1
        
    for i in [0...256]
      # transform the output value:
      # (1) its zero coordinate is at the top
      # (2) it has the range [0..255] but covers +/- voltage
      #
      ch1 = (256 - chunk[i] - @offset) * @gain
      ch2 = (256 - chunk[i+256] - @offset) * @gain
      chd = (256 - chunk[i+512] - @offset) * @gain
      
      
      @push("#{@t} #{ch1}\n")
      @t = @t + @timebase
    # add a blank line after the frame, causes gnuplot to
    # break the plot line at this point, so missed frames show
    # as true gaps in the plot.
    @push('\n')
    # tell the caller we're done with this frame
    cb()
    
module.exports = Plot
