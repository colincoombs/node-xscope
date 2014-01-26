Q = require('q')

UsbDriver   = require('./usbdriver')
Group       = require('./group')
Bits        = require('./bits')
U32         = require('./u32')
U16         = require('./u16')
U8          = require('./u8')
S8          = require('./s8')
Timebase    = require('./timebase')
ChannelGain = require('./channelgain')

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
    
  # @property [Array<Integer>] changed - index of bytes which have changed
  #
  _changed: null
  
  # @property [Boolean] @awgFreqChanged
  #
  _awgFreqChanged: false
  
  # @property [Promise] syncing - sending control bytes to the hardware
  #
  _syncing: null
  
  # @param [Object] usb the usb module (required)
  # @param [Integer] vid USB vendor id (optional)
  # @param [Integer} pid USB product id (optional)
  #
  constructor: (usb, vid=0x16D0, pid=0x06F9) ->
    super(usb, vid, pid)
    @_controlBytes = []
    for i in [0...44]
      @_controlBytes[i] = 0
    @_changed = []
    @_watchers = []
    for i in [0...44]
      @_watchers[i] = []
    @settings = new Group(null, 'scope')
    @_createSettings(@settings)

  # @return [Promise] for the firmware version as a string.
  #
  getFirmwareVersion: () =>
    @_controlTransfer(0x61, 0, 0, 4)
    .then( (data) ->
      data.toString()
    )
    
  saveSettingsToEeprom: () =>
    @_controlTransfer(0x64)
  
  saveAwgWaveToEeprom: () =>
    @_controlTransfer(0x65)
  
  stop: () =>
    @_controlTransfer(0x66)
  
  start: () =>
    @_controlTransfer(0x67)
  
  forceTrigger: () =>
    @_controlTransfer(0x68)
  
  autoSetup: () =>
    @_controlTransfer(0x69)
  
  restoreFactorySettings: () ->
    @_controlTransfer(0x6b)

  # write control settings to device
  #
  syncToHw: () =>
    @_syncing = Q.defer()
    @_awgFreqChanged = false
    @_syncTheRest()
    return @_syncing.promise
  
  # blah
  #
  _syncTheRest: () ->
    if @_changed.length == 0
      if @_awgFreqChanged
        @_controlTransfer(0x63,
          @_controlBytes[40] + (@_controlBytes[41] << 8),
          @_controlBytes[42] + (@_controlBytes[43] << 8),
        ).then( =>
          @_awgFreqChanged = false
          @_syncTheRest()
        ).fail( (err) =>
          @_syncing.reject(err)
        )
      else
        @_syncing.resolve()
    else
      index = @_changed.shift()
      if index >= 40
        @_awgFreqChanged = true
        @_syncTheRest()
      else
        @_controlTransfer(0x62, index, @_controlBytes[index], 0).then( =>
          @_syncTheRest()
        ).fail( (err) =>
          @_syncing.reject(err)
        )
    
  # blah
  #
  syncFromHw: () =>
    p = @_controlTransfer(0x75, 0, 0, 44)
    .then( (data) =>
      #console.log 'read', data.length
      @_changed = []
      for byte, index in data
        @_changed.push(index) if byte != @_controlBytes[index]
        @_controlBytes[index] = byte
      # now alert the watchers
      #console.log 'changed', @_changed
      for index in @_changed
        #console.log 'changed:', index
        for watcher in @_watchers[index]
          #console.log 'watcher', watcher.name()
          watcher.syncFromHw()
      @_changed = []
      return
    )
    return p
   
  # blah
  #
  readControlBytes: (index,nBytes = 1) ->
    return @_controlBytes[index..][...nBytes]

  # blah
  #
  writeControlBytes: (index, bytes) ->
    for byte, i in bytes
      if byte != @_controlBytes[index+i]
        @_changed.push(index+i)
        console.log 'wrteControlByte', index+i, byte, @_controlBytes[index+i]
        @_controlBytes[index+i] = byte

  # blah
  #
  watchControlBytes: (watcher, index, nBytes=1) ->
    for i in [index...index+nBytes]
      @_watchers[i] ?= []
      @_watchers[i].push(watcher)

  # blah
  #
  _createSettings: (top) ->
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
    new U8(nul, this, 'HPos',      14, 0, 8,
      min: 0
      max: 127
    )
    new U8(nul, this, 'VCursorA',  15,
      min: 0
      max: 127
    )
    #
    new U8(nul, this, 'VCursorB',  16,
      min: 0
      max: 127
    )
    new U8(nul, this, 'HCursor1A', 17,
      min: 0
      max: 127
    )
    new U8(nul, this, 'HCursor1B', 18,
      min: 0
      max: 127
    )
    new U8(nul, this, 'HCursor2A', 19,
      min: 0
      max: 127
    )
    #
    new U8(nul, this, 'HCursor2B', 20,
      min: 0
      max: 127
    )
    new U16(trg, this, "post", 22,
      min: 0
      max: 32767
    )
    new U8(trg, this, "source", 24,
      enum: [
        'ch1'
        'ch2'
        'chd0'
        'chd1'
        'chd2'
        'chd3'
        'chd4'
        'chd5'
        'chd6'
        'chd7'
        'ext'
      ]
    )
    new U8(trg, this, "level", 25,
      min: 3
      max: 252
    )
    new U8(trg, this, "window1", 26)
    new U8(trg, this, "window2", 27)
    new U8(trg, this, "timeout", 28)
    new   S8(ch1, this, 'pos',       29,
      min: -128
      max: 0
    )
    new   S8(ch2, this, 'pos',       30,
      min: -128
      max: 0
    )
    new   U8(chd, this, 'pos',       31)
    #
    new   U8(chd, this, 'decode',    32,
      enum: [
        'spi'
        'i2c'
        'rs232'
      ]
    )
    new   U8(awg, this, 'sweep1',    33)
    new   U8(awg, this, 'sweep2',    34)
    new   U8(awg, this, 'swspeed',   35,
      min: 1
      max: 127)
    #
    new   S8(awg, this, 'amp',       36)
    new   U8(awg, this, 'type',      37,
      enum: [
        'noise'
        'sine'
        'square'
        'triangle'
        'exponential'
        'custom'
      ]
    )
    new   U8(awg, this, 'duty',      38,
      min: 1
      max: 255
    )
    new   S8(awg, this, 'offset',    39)
    #
    new  U32(awg, this, 'freq',      40, 4)
    
    return top
  
module.exports = XScopeDriver
