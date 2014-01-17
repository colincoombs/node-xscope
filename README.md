# node-xscope

A node.js driver for [Gabotronics](www.gabotronics.com) Xminilab
oscilloscopes.

### Overview

The Xminilab packs the following features into a very small
hardware module:

* 2-channel analog oscilloscope
* arbitrary waveform generator
* 8-channel logic analyser
* protocol sniffer for I2C, SPI and UART

It has an on-board 2.42" OLED display, plus a USB connection to a
host PC.

The vendor-specific USB protocol is documented, and there is an
open-source PC interface program available.

I wanted to access the device within a coffescript program running
on node.js, so I had to write this driver, which I will make
available as an npm module in the usual way when it works well enough.

### Portability

The 'usb' npm module that I am using is claimed to work on Mac OS and
Windows, so this driver _should_ be equally portable.

I am developing it using Arch Linux on a 64-bit PC, and I have no other
systems available to test it on, so I cannot guarantee anything about
portability, nor can I help you if you experience problems with it on
another OS. Sorry about that.

On the hardware side, the protocol specification seems to apply to
both Xminilab and Xprotolab modules. but all I have to develop it with 
is an Xminilab (hardware v. 2.3, firmware v. 2.25), so once more
I can't comment on its use with other module types.
