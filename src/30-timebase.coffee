xscope = require('..')

class Timebase extends xscope.U8

  constructor: (parent, driver, name, index, options = {}) ->
    options.enum = [
      '8us/div',
      '16us/div',
      '32us/div',
      '64us/div',
      '128us/div',
      '256us/div',
      '500us/div',
      '1ms/div',
      '2ms/div',
      '5ms/div',
      '10ms/div',
      '20ms/div',
      '50ms/div',
      '100ms/div',
      '200ms/div',
      '500ms/div',
      '1s/div',
      '2s/div',
      '5s/div',
      '10s/div',
      '20s/div',
      '50s/div'
    ]
    super(parent, driver, name, index, options)

  secondsPerPixel: () ->
    values = [
      0.0000005,
      0.000001,
      0.000002,
      0.000004,
      0.000008,
      0.000016,
      0.00003125,
      0.0000625,
      0.000125,
      0.0003125,
      0.000625,
      0.00125,
      0.003125,
      0.00625,
      0.0125,
      0.03125,
      0.0625,
      0.125,
      0.3125,
      0.625,
      1.25,
      3.125,
    ]
    return values[@_value]

module.exports.Timebase = Timebase
