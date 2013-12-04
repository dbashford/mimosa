"use strict"

AbstractUnderscoreCompiler = require './underscore'

module.exports = class UnderscoreCompiler extends AbstractUnderscoreCompiler

  clientLibrary: "underscore"
  libName : 'underscore'

  @defaultExtensions = ["tpl", "underscore"]

  constructor: (config, @extensions) ->
    super(config)

