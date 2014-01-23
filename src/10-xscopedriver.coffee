Q = require('q')

UsbDriver   = require('./01-usbdriver').UsbDriver
Group       = require('./20-group').Group
Bits        = require('./20-bits').Bits
U32         = require('./20-u32').U32
U16         = require('./20-u16').U16
U8          = require('./20-u8').U8
S8          = require('./20-s8').S8
Timebase    = require('./30-timebase').Timebase
ChannelGain = require('./30-channelgain').ChannelGain

# my controlBytes class
#
class XScopeDriver extends UsbDriver

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
    @settings = new Group(null, 'scope')
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
    ch1 = new Group(top, 'ch1')
    ch2 = new Group(top, 'ch2')
    chd = new Group(top, 'chd')
    dsp = new Group(top, 'display')
    trg = new Group(top, 'trigger')
    awg = new Group(top, 'awg')
    nul = new Group(null, 'tbd')
    new   Timebase(top, this, "timebase", 0)
    #new   U8(ch1, this, 'control',    1)
    new Bits(ch1, this, "on", 1, 0, 1)
    new Bits(ch1, this, "invert", 1, 4, 1)
    new Bits(ch1, this, "average", 1, 4, 1)
    new Bits(ch1, this, "math", 1, 6, 2,
      enum: [
        'off',
        'multiply',
        'X-02',
        'subtract'
      ])
    new   U8(ch2, this, 'control',    2)
    new   U8(chd, this, 'control',    3)
    #
    new   U8(chd, this, 'mask',       4)
    new Bits(trg, this, "mode",   5, 0, 3,
      enum: [
        undefined,
        'normal',
        undefined,
        'single',
        'auto',
        undefined,
        undefined,
        undefined
      ])
    new Bits(trg, this, "direction", 5, 3, 1)
    new Bits(trg, this, 'round',      5, 4, 1)
    new Bits(trg, this, "type",      5, 5, 3,
      enum: [
        'dual-edge',
        'slope',
        'window',
        undefined,
        'edge',
        undefined,
        undefined,
        undefined
      ])
    new Bits(nul, this, 'MCursors',   6, 0, 8)
    new Bits(dsp, this, 'grid',       7, 0, 2)
    new Bits(dsp, this, 'elastic',    7, 2, 1)
    new Bits(dsp, this, 'invert',     7, 3, 1)
    new Bits(dsp, this, 'flip',       7, 4, 1)
    new Bits(dsp, this, 'persist',    7, 5, 1)
    new Bits(dsp, this, 'line',       7, 6, 1)
    #new Bits(dsp, this, 'settings',   7, 7, 1)
    #
    #new Bits(nul, this, 'MFFT',       8, 0, 8)
    #new Bits(awg, this, 'Sweep',      9, 0, 8)
    #new Bits(nul, this, 'Sniffer',   10, 0, 8)
    new Bits(top, this, "stopped",   11, 4, 1)
    new Bits(top, this, "triggered", 11, 5, 1)
    new   ChannelGain(ch1, this, "gain",      12)
    new   ChannelGain(ch2, this, 'gain',      13)
    #new Bits(nul, this, 'HPos',      14, 0, 8)
    #new Bits(nul, this, 'VCursorA',  15, 0, 8)
    #
    #new Bits(nul, this, 'VCursorB',  16, 0, 8)
    #new Bits(nul, this, 'HCursor1A', 17, 0, 8)
    #new Bits(nul, this, 'HCursor1B', 18, 0, 8)
    #new Bits(nul, this, 'HCursor2A', 19, 0, 8)
    #
    #new Bits(nul, this, 'HCursor2B', 20, 0, 8)
    new U16(trg, this, "post", 22)
    new U8(trg, this, "source", 24)
    new U8(trg, this, "level", 25)
    new U8(trg, this, "window1", 26)
    new U8(trg, this, "window2", 27)
    new U8(trg, this, "timeout", 28)
    new   S8(ch1, this, 'pos',       29)
    new   S8(ch2, this, 'pos',       30)
    new   U8(chd, this, 'pos',       31)
    #
    new   U8(chd, this, 'decode',    32)
    new   U8(awg, this, 'sweep1',    33)
    new   U8(awg, this, 'sweep2',    34)
    new   U8(awg, this, 'swspeed',   35)
    #
    new   S8(awg, this, 'amp',       36)
    new   U8(awg, this, 'type',      37)
    new   U8(awg, this, 'duty',      38)
    new   S8(awg, this, 'offset',    39)
    #
    new  U32(awg, this, 'freq',      40, 4)
    
    return top
  
module.exports.XScopeDriver = XScopeDriver
