"use strict"

JSCompiler = require "./javascript"

module.exports = class IcedCompiler extends JSCompiler.JSCompiler
  libName: 'iced-coffee-script'
  @defaultExtensions = ["iced"]

  constructor: (config, @extensions) ->
    @icedConfig = config.iced
    super()

  registration: (config, register) ->
    super config, register
    JSCompiler.cleanUpSourceMapsRegister register, @extensions, @icedConfig

  compile: (file, cb) ->
    @_icedAndCoffeeCompile file, @icedConfig, cb