class FakeDriver

  constructor: (@values = {}) ->
    #
    
  watchControlBytes: () ->
    return
  
  readControlBytes: (index, length=1) ->
    #console.log 'RCB', index, length
    result = []
    for i in [0...length]
      throw new Error('wrong index') unless @values[index]?
      result.push(@values[index])
      index = index + 1
    #console.log 'RCB ->', result
    return result
  
  writeControlBytes: (index, bytes) ->
    #console.log 'WCB', index, bytes
    for byte, i in bytes
      @values[index+i] = byte
  
module.exports = FakeDriver
