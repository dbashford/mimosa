"use strict"

jade = require 'jade'

TemplateCompiler = require './template'

module.exports = class JadeCompiler extends TemplateCompiler

  clientLibrary: "jade-runtime"

  @prettyName        = "Jade - http://jade-lang.com/"
  @defaultExtensions = ["jade"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(['#{@libraryPath()}'], function (jade){ var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, templateName, cb) =>
    try
      output = jade.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName
    catch err
      error = err
    cb(error, output)
