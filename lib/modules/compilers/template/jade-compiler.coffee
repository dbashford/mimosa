jade = require 'jade'

AbstractTemplateCompiler = require './template'

module.exports = class JadeCompiler extends AbstractTemplateCompiler

  clientLibrary: "jade-runtime"

  @prettyName        = "Jade - http://jade-lang.com/"
  @defaultExtensions = ["jade"]

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: ->
    "define(['#{@libraryPath()}'], function (jade){ var templates = {};\n"

  amdSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      output = jade.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName
    catch err
      error = err
    cb(error, output)
