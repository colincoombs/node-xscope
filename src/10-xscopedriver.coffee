Q = require('q')

xscope = require('..')

# my controlBytes class
#
class XScopeDriver extends xscope.UsbDriver

  # @property [Setting] the group of interpreted control settings
  #
  settings: null

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
    @settings = new xscope.Group(null, 'scope')
    @createSettings(@settings)

  # @return [Promise] for the firmware version as a string.
  #
  getFirmwareVersion: () =>
    @_controlTransfer(0x61, 0, 0, 4)
    .then( (data) ->
      data.toString()
    )
    
  saveSettingsToEeprom: () ->
    @_controlTransfer(0x64)
    
  saveAwgWaveToEeprom: () ->
    @_controlTransfer(0x65)
    
  stop: () =>
    @_controlTransfer(0x66)

  start: () =>
    @_controlTransfer(0x67)
    
  forceTrigger: () ->
    @_controlTransfer(0x68)
    
  autoSetup: () ->
    @_controlTransfer(0x69)
    
  restoreFactorySettings: () ->
    @_controlTransfer(0x6b)

  syncFromHw: () =>
    p = @_controlTransfer(0x75, 0, 0, 44)
    .then( (data) =>
      #console.log 'read', data.length
      for b, i in data
        @_controlBytes[i] = b
      @settings.syncFromHw()
      return
    )
    return p
   
  readControlByte: (index) ->
    @_controlBytes[index]

  writeControlByte: (index, value) ->
    @_controlBytes[index] = value

  createSettings: (top) ->
    ch1 = new xscope.Group(top, 'ch1')
    ch2 = new xscope.Group(top, 'ch2')
    chd = new xscope.Group(top, 'chd')
    dsp = new xscope.Group(top, 'display')
    trg = new xscope.Group(top, 'trigger')
    awg = new xscope.Group(top, 'awg')
    nul = new xscope.Group(null, 'tbd')
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
    #new   xscope.U8(ch1, this, 'control',    1)
    new xscope.Bits(ch1, this, "on", 1, 0, 1)
    new xscope.Bits(ch1, this, "invert", 1, 4, 1)
    new xscope.Bits(ch1, this, "average", 1, 4, 1)
    new xscope.Bits(ch1, this, "math", 1, 6, 2,
      enum: [
        'off',
        'multiply',
        'X-02',
        'subtract'
      ])
    new   xscope.U8(ch2, this, 'control',    2)
    new   xscope.U8(chd, this, 'control',    3)
    #
    new   xscope.U8(chd, this, 'mask',       4)
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
    new xscope.Bits(trg, this, 'round',      5, 4, 1)
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
    new xscope.Bits(nul, this, 'MCursors',   6, 0, 8)
    new xscope.Bits(dsp, this, 'grid',       7, 0, 2)
    new xscope.Bits(dsp, this, 'elastic',    7, 2, 1)
    new xscope.Bits(dsp, this, 'invert',     7, 3, 1)
    new xscope.Bits(dsp, this, 'flip',       7, 4, 1)
    new xscope.Bits(dsp, this, 'persist',    7, 5, 1)
    new xscope.Bits(dsp, this, 'line',       7, 6, 1)
    #new xscope.Bits(dsp, this, 'settings',   7, 7, 1)
    #
    #new xscope.Bits(nul, this, 'MFFT',       8, 0, 8)
    #new xscope.Bits(awg, this, 'Sweep',      9, 0, 8)
    #new xscope.Bits(nul, this, 'Sniffer',   10, 0, 8)
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
    #new   xscope.U8(ch2, this, 'gain',      13)
    #new xscope.Bits(nul, this, 'HPos',      14, 0, 8)
    #new xscope.Bits(nul, this, 'VCursorA',  15, 0, 8)
    #
    #new xscope.Bits(nul, this, 'VCursorB',  16, 0, 8)
    #new xscope.Bits(nul, this, 'HCursor1A', 17, 0, 8)
    #new xscope.Bits(nul, this, 'HCursor1B', 18, 0, 8)
    #new xscope.Bits(nul, this, 'HCursor2A', 19, 0, 8)
    #
    #new xscope.Bits(nul, this, 'HCursor2B', 20, 0, 8)
    new xscope.U16(trg, this, "post", 21)
    new xscope.U8(trg, this, "source", 24)
    new xscope.U8(trg, this, "level", 25)
    new xscope.U8(trg, this, "window1", 26)
    new xscope.U8(trg, this, "window2", 27)
    new xscope.U8(trg, this, "timeout", 28)
    new   xscope.S8(ch1, this, 'pos',       29)
    new   xscope.S8(ch2, this, 'pos',       30)
    new   xscope.U8(chd, this, 'pos',       31)
    #
    new   xscope.U8(chd, this, 'decode',    32)
    new   xscope.U8(awg, this, 'sweep1',    33)
    new   xscope.U8(awg, this, 'sweep2',    34)
    new   xscope.U8(awg, this, 'swspeed',   35)
    #
    new   xscope.S8(awg, this, 'amp',       36)
    new   xscope.U8(awg, this, 'type',      37)
    new   xscope.U8(awg, this, 'duty',      38)
    new   xscope.S8(awg, this, 'offset',    39)
    #
    #new xscope.Item(awg, this, 'freq',      40, 4) # U32
    
    return top
  
module.exports.XScopeDriver = XScopeDriver
