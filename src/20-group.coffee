xscope = require('..')

class Group extends xscope.Setting

  constructor: (parent, name) ->
    super(parent, null, name)
    @_value = {}
  
  add: (component) ->
    #console.log 'add', component._name, @value()
    if @_value[component._name]?
      throw new Error('component already defined')
    @_value[component._name] = component
    
  value: () ->
    result = {}
    for n, v of @_value
      result[n] = v.value()
    return result

  configure: (value) ->
    #console.log 'configure', value, @_value
    for n, v of value
      if n of @_value
        @_value[n].configure(v)
      else
        throw new Error('component '+n+' unknown in '+@name())

  syncFromHw: () ->
    for n, v of @_value
      v.syncFromHw()

  syncToHw: () ->
    for n, v of @_value
      v.syncToHw()

module.exports.Group = Group
