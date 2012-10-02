_ = require 'underscore'

AbstractTemplateCompiler = require './template'

module.exports = class HTMLCompiler extends AbstractTemplateCompiler

  clientLibrary: null

  @prettyName        = "HTML - Just Plain HTML Snippets, no compiling"
  @defaultExtensions = ["template"]

  constructor: (config, @extensions) ->
    super(config)

  filePrefix: ->
    "define(function () { var templates = {};\n"

  fileSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    # we don't want underscore to actually work, just to wrap stuff
    _.templateSettings =
      evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
      interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g

    try
      compiledOutput = _.template(file.inputFileText)
      output = "#{compiledOutput}()"
    catch err
      error = "#{file.inputFileName}, #{err}\n"

    # set it back
    _.templateSettings =
      evaluate    : /<%([\s\S]+?)%>/g,
      interpolate : /<%=([\s\S]+?)%>/g

    cb(error, output)
