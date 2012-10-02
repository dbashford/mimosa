hogan = require "hogan.js"

AbstractTemplateCompiler = require './template'

module.exports = class HoganCompiler extends AbstractTemplateCompiler

  clientLibrary: "hogan-template"

  @prettyName        = "Hogan - http://twitter.github.com/hogan.js/"
  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config, @extensions) ->
    super(config)

  filePrefix: ->
    "define(['#{@libraryPath()}'], function (Hogan){ var templates = {};\n"

  fileSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) ->
    try
      compiledOutput = hogan.compile(file.inputFileText, {asString:true})
      output = "templates['#{templateName}'] = new Hogan.Template(#{compiledOutput});\n"
    catch err
      error = "#{file.inputFileName}, #{err}\n"

    cb(error, output)
