#! /usr/bin/env coffee

xscope = require('..')

# pending ideas:
# -------------
#
# ummm
#

scope = new xscope.XScope()

scope.open(
  
  timebase: '500us/div'
  ch1:
    gain: '2.56V/div'
  awg:
    type: 'sine'
    
).then( =>
  
  console.log scope.settings.value()
  
  formatter = new xscope.Plot(
    scope.secondsPerPixel(),
    scope.voltsPerPixel(1),
    scope.post() - 256
  )
  drawer = new xscope.Gnuplot()
  formatter.pipe(drawer)

  scope.startStream(1, formatter)

).then( =>

  scope.stop()

).then( =>

  scope.close()

).done()
