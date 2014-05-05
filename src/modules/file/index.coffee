"use strict"

init = require './init'
beforeRead = require './beforeRead'
read = require './read'
write = require './write'
del = require './delete'
clean = require './clean'

modules = [init, beforeRead, read, write, del, clean]

exports.registration = (config, register) ->
  modules.forEach (module) ->
    module.registration(config, register)