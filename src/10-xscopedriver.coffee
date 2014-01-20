Q = require('q')

xscope = require('..')

# my controlBytes class
#
class XScopeDriver extends xscope.UsbDriver

  # @property [Array<Integer>] to hold the scope's control data
  # @protected
  #
  _controlBytes: null
    
  # @param [Object] usb the usb module (required)
  # @param [Integer] vid USB vendor id (optional)
  # @param [Integer} pid USB product id (optional)
  #
  constructor: (usb, vid=0x16D0, pid=0x06F9) ->
    super(usb, vid, pid)
    @_controlBytes = []
    for i in [0...44]
      @_controlBytes[i] = 0
    
  # @return [Promise] for the firmware version as a string.
  #
  getFirmwareVersion: () =>
    @_controlTransfer(0x61, 0, 0, 4)
    .then( (data) ->
      data.toString()
    )
    
  stop: () =>
    @_controlTransfer(0x66)

  start: () =>
    @_controlTransfer(0x67)
    
  syncFromHw: () =>
    p = @_controlTransfer(0x75, 0, 0, 44)
    .then( (data) =>
      #console.log 'read', data.length
      for b, i in data
        @_controlBytes[i] = b
      return
    )
    return p
   
  readControlByte: (index) ->
    @_controlBytes[index]

  writeControlByte: (index, value) ->
    @_controlBytes[index] = value

  createSettings: () ->
    top = new xscope.Group(null, 'scope')
    ch1 = new xscope.Group(top, 'ch1')
    trg = new xscope.Group(top, 'trigger')
    new   xscope.U8(top, this, "timebase",   0,
      enum: [
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
      ])
    new xscope.Bits(trg, this, "mode",   5, 0, 3,
      enum: [
        'X-00',
        'normal',
        'X-02',
        'single',
        'auto',
        'X-05',
        'X-06',
        'X-07'
      ])
    new xscope.Bits(trg, this, "direction", 5, 3, 1)
    new xscope.Bits(trg, this, "type",      5, 5, 3,
      enum: [
        'dual-edge',
        'slope',
        'window',
        'X-03',
        'edge',
        'X-05',
        'X-06',
        'X-07'
      ])
    new xscope.Bits(top, this, "stopped",   11, 4, 1)
    new xscope.Bits(top, this, "triggered", 11, 5, 1)
    new   xscope.U8(ch1, this, "gain",      12,
      enum: [
        '5.12V/div',
        '2.56V/div',
        '1.28V/div',
        '640mV/div',
        '320mV/div',
        '160mV/div',
        '80mV/div'
      ])
    return top
  
module.exports.XScopeDriver = XScopeDriver
