dust = require 'dustjs-linkedin'

AbstractTemplateCompiler = require './template'

module.exports = class DustCompiler extends AbstractTemplateCompiler

  clientLibrary: "dust"
  handlesNamespacing: true

  @prettyName        = "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = ["dust"]

  constructor: (config, @extensions) ->
    super(config)

  filePrefix: ->
    "define(['#{@libraryPath()}'], function (dust){ "

  fileSuffix: ->
    'return dust; });'

  compile: (file, templateName, cb) ->
    try
      output = dust.compile file.inputFileText, templateName
    catch err
      error = "#{file.inputFileName}, #{err}\n"
    cb(error, output)
