iced = require 'iced-coffee-script'

JSCompiler = require "./javascript"

module.exports = class IcedCompiler extends JSCompiler

  @prettyName        = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = ["iced"]

  constructor: (config, @extensions) ->
    super()

  compile: (config, options, cb) ->
    try
      output = iced.compile file.inputFileText
    catch err
      error = {text:"#{file.inputFileName}, #{err}"}
    cb(error, output)