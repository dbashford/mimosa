"use strict"

_ = require 'underscore'

TemplateCompiler = require './template'

module.exports = class HTMLCompiler extends TemplateCompiler

  clientLibrary: null

  @prettyName        = "HTML - Just Plain HTML Snippets, no compiling"
  @defaultExtensions = ["template"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(function () { var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, cb) =>
    # we don't want underscore to actually work, just to wrap stuff
    _.templateSettings =
      evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
      interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g

    try
      compiledOutput = _.template(file.inputFileText)
      output = "#{compiledOutput.source}()"
    catch err
      error = err

    # set it back
    _.templateSettings =
      evaluate    : /<%([\s\S]+?)%>/g,
      interpolate : /<%=([\s\S]+?)%>/g

    cb(error, output)
