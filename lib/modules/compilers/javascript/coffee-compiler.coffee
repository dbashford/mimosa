coffee = require 'coffee-script'

JSCompiler = require "./javascript"

module.exports = class CoffeeCompiler extends JSCompiler

  @prettyName        = "(*) CoffeeScript - http://coffeescript.org/"
  @defaultExtensions = ["coffee"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super()

  compile: (file, cb) ->
    try
      output = coffee.compile file.inputFileText
    catch err
      error = {text:"#{file.inputFileName}, #{err}"}
    cb(error, output)
