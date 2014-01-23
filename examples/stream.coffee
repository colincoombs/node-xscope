#! /usr/bin/env coffee

xscope = require('..')
usb    = require('usb')

# pending ideas:
# -------------
# * move 'limiter' into the XScope class, since its use is so vital
#   for anything streaming. Therefor the 'limit' becomes some kind
#   of parameter to startStream (?)
#
# * give XScope a 'pipe' method to hide the internal transforms --
#   or is this to be hidden within the startStream call:
#       scope.limit(1).pipe(blah).startStream() ???
#
# ummm - there is no *point* in startStream without soomewhere
# to pipe the output to, similarly no *point* to setting up a pipe
# without using streaming mode!
#
# So... scope.startStream(nFrames, pipeToHandleTheFrames) seems
# right.
# But: the pipe parameter is not optional, the nFrames often has
# the default value of 1, so it should come after?
# But: this way round seems more natural to use.

scope = new xscope.XScope(usb)

limiter = new xscope.Limit()
limiter.then( =>
  scope.stopStream()
)

scope.open().then( =>
  scope.syncFromHw()
).then( () => 
  limiter
    .pipe(new xscope.Plot(
      scope.settings._value.timebase.secondsPerPixel(),
      scope.settings._value.ch1._value.gain.voltsPerPixel(),
      scope.settings._value.trigger._value.post.value() - 256
    ))
    .pipe(new xscope.Gnuplot())
).then( => 
  scope.start()
).then( => 
  scope.startStream(limiter) 
).then( =>
  scope.stop()
).then( =>
  scope.close()
).done()
