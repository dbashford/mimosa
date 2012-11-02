"use strict"

init = require './init'
beforeRead = require './beforeRead'
read = require './read'
write = require './write'
del = require './delete'
modules = [init, beforeRead, read, write, del]

class MimosaFileModule

  registration: (config, register) ->
    modules.forEach (module) ->
      module.registration(config, register)

module.exports = new MimosaFileModule()