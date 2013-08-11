"use strict"

AbstractUnderscoreCompiler = require './underscore'

module.exports = class UnderscoreCompiler extends AbstractUnderscoreCompiler

  clientLibrary: "underscore"
  libName : 'underscore'

  @prettyName        = "Underscore - http://underscorejs.org/#template"
  @defaultExtensions = ["tpl", "underscore"]

  constructor: (config, @extensions) ->
    super(config)

