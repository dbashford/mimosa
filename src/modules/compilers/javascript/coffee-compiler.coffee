"use strict"

JSCompiler = require "./javascript"

module.exports = class CoffeeCompiler extends JSCompiler.JSCompiler

  libName: 'coffee-script'

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee", "litcoffee"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    @coffeeConfig = config.coffeescript
    super()

  registration: (config, register) ->
    super config, register
    JSCompiler.cleanUpSourceMapsRegister register, @extensions, @coffeeConfig

  compile: (file, cb) ->
    @_icedAndCoffeeCompile file, @coffeeConfig, cb