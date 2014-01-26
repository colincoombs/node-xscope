stream = require('stream')
Q      = require('q')
# apply a limit to the number of frames catured.
#
class Limit extends stream.Transform

  # @property [Promise] to be resolved at the given no. of frames
  #
  deferred: null
  
  # @property [Integer] current frame count
  #
  count: 0
  
  # @property [Integer] maximum frames desired
  #
  limit: 1
  
  # @param [Integer] limit - maximum number of frames to pass
  # @param [Object] options - for the superclass Transform
  constructor: (@limit, stopper, options={}) ->
    super(options)
    @limit ?= 1
    @count = 0
    @deferred = Q.defer()
    @deferred.promise.then(stopper) if stopper?
    
  # handle each frame
  # @param [Buffer] chunk - captured data
  # @param [String] encoding - irrelevant
  # @param [Function] cb - callback to upstream
  #
  _transform: (chunk, encoding, cb) ->
    # pass the data on downstream if not yet complete.
    # when count expires, throw away any further frames
    @push(chunk) if @count < @limit
    @count = @count + 1
    # tell upstream that we've handled this chunk
    cb()
    # sound the alarm if the limit has been reached
    @deferred.resolve() if (@count == @limit)

module.exports = Limit

