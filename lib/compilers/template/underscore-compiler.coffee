AbstractUnderscoreCompiler = require './underscore'

module.exports = class UnderscoreCompiler extends AbstractUnderscoreCompiler

  clientLibrary: "underscore"

  @prettyName        = -> "Underscore - http://underscorejs.org/#template"
  @defaultExtensions = -> ["tpl", "underscore"]

  constructor: (config) ->
    super(config)

  getLibrary: ->
    require 'underscore'

