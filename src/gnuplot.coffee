stream = require('stream')
os     = require('os')
fs     = require('fs')

# class to take a stream of plotting co-ordinates and transform
# this into a gnuplot image.
#
# All we want to do is to intercept the 'end()' call so that
# we know that the data stream is complete before we
# invoke gnuplot.
#
class Gnuplot extends stream.Transform

  # @parameter [Object] options for the superclass Transform
  # we pipe all the data we receive to a temporary file.
  #
  constructor: (options) ->
    super(options)
    @fn = "#{os.tmpdir()}/#{new Date().getTime()}.plot"
    @tmpfile = fs.createWriteStream(@fn)
    @pipe(@tmpfile)

  _transform: (chunk, encoding, cb) ->
    @push(chunk)
    cb() if cb?
    
  # In this method, we know when all the data has been passed and
  # we can safely start gnuplot which does not do blocking reads
  # on its input files.
  #
  _flush: (cb) ->
    @tmpfile.end()
    child = require('child_process').spawn(
      '/usr/bin/gnuplot', [
        # add parameters to taste ...
        '-e', 'set grid',
        '-e', 'set yrange [-5:5]',
        '-e', "plot '#{@fn}' using 1:2 with lines",
        '--persist'
      ]
    )
    child.stdout.pipe(process.stdout)
    child.stderr.pipe(process.stderr)
    cb() if cb?

module.exports = Gnuplot

