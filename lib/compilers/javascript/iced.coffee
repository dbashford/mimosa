AbstractJavascriptCompiler = require './javascript-compiler'
iced = require 'iced-coffee-script'

module.exports = class IcedCompiler extends AbstractJavascriptCompiler

  constructor: (config) -> super(config)

  compile: (cs, fileName, destinationFile, callback) ->
    try
      output = iced.compile cs
    catch err
      error = err
    callback(error, output, destinationFile)