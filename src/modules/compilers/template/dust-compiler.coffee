"use strict"

TemplateCompiler = require './template'

module.exports = class DustCompiler extends TemplateCompiler

  clientLibrary: "dust"
  handlesNamespacing: true
  libName: "dustjs-linkedin"

  @defaultExtensions = ["dust"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is "amd"
      "define(['#{@libraryPath()}'], function (dust){ "
    else if config.template.wrapType is "common"
      "var dust = require('#{config.template.commonLibPath}');\n"
    else
      ""

  suffix: (config) ->
    if config.template.wrapType is "amd"
      'return dust; });'
    else if config.template.wrapType is "common"
      "\nmodule.exports = dust;"
    else
      ""

  compile: (file, cb) ->
    try
      output = @compilerLib.compile file.inputFileText, file.templateName
    catch err
      error = err
    cb(error, output)
