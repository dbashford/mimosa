"use strict"

TemplateCompiler = require './template'

module.exports = class HTMLCompiler extends TemplateCompiler

  clientLibrary: null
  libName: "underscore"

  @prettyName        = "HTML - Just Plain HTML Snippets, no compiling"
  @defaultExtensions = ["template"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is 'amd'
      "define(function () { var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.wrapType is 'amd'
      'return templates; });'
    else if config.template.wrapType is "common"
      "\nmodule.exports = templates;"
    else
      ""

  compile: (file, cb) =>
    # we don't want underscore to actually work, just to wrap stuff
    @compilerLib.templateSettings =
      evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
      interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g

    try
      compiledOutput = @compilerLib.template(file.inputFileText)
      output = "#{compiledOutput.source}()"
    catch err
      error = err

    # set it back
    @compilerLib.templateSettings =
      evaluate    : /<%([\s\S]+?)%>/g,
      interpolate : /<%=([\s\S]+?)%>/g

    cb(error, output)
