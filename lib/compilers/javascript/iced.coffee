AbstractJavaScriptCompiler = require './javascript-compiler'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractJavaScriptCompiler

  constructor: (config) ->
    super(config)
    @extensions = config?.extensions or ["coffee"]

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = iced.compile cs
    catch err
      error = err
    callback(error, output, destinationFile)