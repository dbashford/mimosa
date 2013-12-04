"use strict"

TemplateCompiler = require './template'

module.exports = class HoganCompiler extends TemplateCompiler

  clientLibrary: "hogan-template"
  libName: "hogan.js"

  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is 'amd'
      "define(['#{@libraryPath()}'], function (Hogan){ var templates = {};\n"
    else if config.template.wrapType is "common"
      "var Hogan = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.wrapType is 'amd'
      'return templates; });'
    else if config.template.wrapType is "common"
      "\nmodule.exports = templates;"
    else
      ""

  compile: (file, cb) ->
    try
      compiledOutput = @compilerLib.compile(file.inputFileText, {asString:true})
      output = "templates['#{file.templateName}'] = new Hogan.Template(#{compiledOutput});\n"
    catch err
      error = err
    cb(error, output)
