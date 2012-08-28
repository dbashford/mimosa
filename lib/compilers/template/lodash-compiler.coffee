AbstractUnderscoreCompiler = require './underscore'

module.exports = class LodashCompiler extends AbstractUnderscoreCompiler

  clientLibrary: "lodash"

  @prettyName        = "LoDash - http://lodash.com/docs#template"
  @defaultExtensions = ["tpl", "lodash"]

  constructor: (config) ->
    super(config)

  getLibrary: ->
    require 'lodash'

