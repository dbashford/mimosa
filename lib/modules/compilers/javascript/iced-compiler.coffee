iced = require 'iced-coffee-script'

JSCompiler = require "./javascript-compiler"

module.exports = class IcedCompiler extends JSCompiler

  @prettyName        = "Iced CoffeeScript - http://maxtaco.github.com/coffee-script/"
  @defaultExtensions = ["iced"]

  constructor: (config, @extensions) ->

  compile: (config, options, next) ->
    try
      options.output = iced.compile options.fileContent
    catch err
      error = {text:"#{options.inputFile}, #{err}"}
      return next(error)
    next()