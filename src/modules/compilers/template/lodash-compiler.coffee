"use strict"

AbstractUnderscoreCompiler = require './underscore'

module.exports = class LodashCompiler extends AbstractUnderscoreCompiler

  clientLibrary: "lodash"
  libName: 'lodash'

  @defaultExtensions = ["tmpl", "lodash"]

  constructor: (config, @extensions) ->
    super(config)
