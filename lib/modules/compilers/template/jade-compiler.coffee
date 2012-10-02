jade = require 'jade'

AbstractTemplateCompiler = require './template'

module.exports = class JadeCompiler extends AbstractTemplateCompiler

  clientLibrary: "jade-runtime"

  @prettyName        = "Jade - http://jade-lang.com/"
  @defaultExtensions = ["jade"]

  constructor: (config, @extensions) ->
    super(config)

  filePrefix: ->
    "define(['#{@libraryPath()}'], function (jade){ var templates = {};\n"

  fileSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      output = jade.compile file.intputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName
    catch err
      error = "#{file.inputFileName}, #{err}\n"

    cb(error, output)
