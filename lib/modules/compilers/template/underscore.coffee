AbstractTemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)

  filePrefix: ->
    "define(['#{@libraryPath()}'], function (_) { var templates = {};\n"

  fileSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      compiledOutput = @getLibrary().template(file.inputFileText)
      output = compiledOutput.source
    catch err
      error = "#{file.inputFileName}, #{err}\n"

    cb(error, output)
