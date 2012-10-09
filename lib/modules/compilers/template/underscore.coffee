AbstractTemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)

  amdPrefix: ->
    "define(['#{@libraryPath()}'], function (_) { var templates = {};\n"

  amdSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      compiledOutput = @getLibrary().template(file.inputFileText)
      output = compiledOutput.source
    catch err
      error = err
    cb(error, output)
