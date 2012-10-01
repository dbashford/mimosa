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
      output = coffee.compile file.sourceFileText
    catch err
      error = {text:"#{file.sourceFileName}, #{err}"}
    cb(error, output)
