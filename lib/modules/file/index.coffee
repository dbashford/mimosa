init = require './init'
beforeRead = require './beforeRead'
read = require './read'
write = require './write'
del = require './delete'
modules = [init, beforeRead, read, write, del]

class MimosaFileModule

  lifecycleRegistration: (config, register) ->
    modules.forEach (module) ->
      module.lifecycleRegistration(config, register)

module.exports = new MimosaFileModule()