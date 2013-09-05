"use strict"

TemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends TemplateCompiler

  constructor: (config) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is 'amd'
      "define(['#{@libraryPath()}'], function (_) { var templates = {};\n"
    else if config.template.wrapType is "common"
      "var _ = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
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
    try
      compiledOutput = @compilerLib.template(file.inputFileText)
      output = compiledOutput.source
    catch err
      error = err
    cb(error, output)
