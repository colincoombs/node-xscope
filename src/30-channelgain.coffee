U8 = require('./20-u8').U8

class ChannelGain extends U8

  constructor: (parent, driver, name, index, options = {}) ->
    options.enum = [
      '5.12V/div',
      '2.56V/div',
      '1.28V/div',
      '640mV/div',
      '320mV/div',
      '160mV/div',
      '80mV/div'
      ]
    super(parent, driver, name, index, options)

  voltsPerPixel: () ->
    vpp = [
      0.32,
      0.16,
      0.08,
      0.04,
      0.02,
      0.01,
      0.005
    ]
    return vpp[@_value]
  
module.exports.ChannelGain = ChannelGain
