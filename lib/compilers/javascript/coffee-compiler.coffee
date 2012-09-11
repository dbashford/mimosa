AbstractJavascriptCompiler = require './javascript'
coffee = require 'coffee-script'

module.exports = class CoffeeCompiler extends AbstractJavascriptCompiler

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  compile: (fileName, text, destinationFile, callback) ->
    try
      output = coffee.compile text
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)