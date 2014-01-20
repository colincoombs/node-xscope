# getconfig example __DRAFT VERSION to check formatting & stuff__

This example shows how you could save the current control setup
of the Xminilab to a file.

__ To understand this program, you will first need to understand
'promises'. __

## Installation

** To be written more clealy!**

The use of '..' to require the xscope package assumes that you are
running this script in its current place in the directory tree.

## The code

First, we have a pretty standard prelude of node.js stuff.

    #! /usr/bin/env coffee
    
    fs      = require('fs')
    program = require('commander')
    xscope  = require('..')

The next stanza defines and parses the program's options. Here,
I have provided for two settings:

* **--fake** uses my fake-usb module which is good for development
  or where you have no real hardware plugged in
* **--json**  outputs 'proper' JSON syntax which can easily be
  processed by other programs (e.g. the forthcoming _setconfig_
  utility). Without this option, the program outputs a Javascript
  object value, which is more readable to humans, less so for
  programs.

It seems I must write something herfe, just to separate the itemized
stuff before from the code section after.
  
    program
      .option('-k, --fake', 'use fake usb module')
      .option('-j, --json', 'output JSON rather than javascript')
      .version('0.0.1')
      .parse(process.argv)
    
    if program.fake
      usb = require('../fake/usb')
      usb.configure { findDevice: true }
    else
      usb = require('usb')

It seems we have to create the result object here in the top scope,
otherwise the actions in the various callbacks below will each refer
to a different, local, variable called 'settings'. Notice also that
the callbacks must always use the 'fat arrow' syntax

    settings = {}
    
Now we can get down to business. All the methods of the driver class
return promises to handle their asynchronous nature, so we must
express the intended sequence of calls and other actions in a chain
of 'then' calls.

    driver = new xscope.XScopeDriver(usb)
    
    driver.open()
    .then( =>
      driver.syncFromHw()
    ).then( =>
      settings = driver.createSettings()
      settings.syncFromHw()
    ).then( =>
      if program.json
        process.stdout.write JSON.stringify settings.value()
        process.stdout.write '\n'
      else
        console.log settings.value()
    ).done()

Just to bang on about promises some more, notice control reaches this
point in the program once the chain of promises has been built up,
none of the above actions have actually happened yet, as far as you
can tell. So DON'T PLACE ANY MORE CODE HERE!

Also the final call to 'done()' is needed to pick up any exceptions
which may have been thrown during the course of the action.
