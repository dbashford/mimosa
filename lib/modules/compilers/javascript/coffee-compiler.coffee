coffee = require 'coffee-script'

JSCompiler = require "./javascript-compiler"

module.exports = class CoffeeCompiler extends JSCompiler

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee"]
  @isDefault         = true

  constructor: (config, @extensions) ->

  compile: (config, options, next) ->
    try
      options.output = coffee.compile options.fileContent
    catch err
      error = {text:"#{options.inputFile}, #{err}"}
      return next(error)
    next()
