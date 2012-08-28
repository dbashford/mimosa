AbstractJavascriptCompiler = require './javascript'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractJavascriptCompiler

  @prettyName        = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = ["iced"]

  constructor: (config) ->
    super(config)

  compile: (fileName, text, destinationFile, callback) ->
    try
      output = iced.compile text
    catch err
      error = "#{fileName}, #{err}"
    callback(error, output, destinationFile)