"use strict"

TemplateCompiler = require './template'

module.exports = class JadeCompiler extends TemplateCompiler

  clientLibrary: "jade-runtime"
  libName: 'jade'

  @defaultExtensions = ["jade"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is 'amd'
      "define(['#{@libraryPath()}'], function (jade){ var templates = {};\n"
    else if config.template.wrapType is "common"
      "var jade = require('#{config.template.commonLibPath}');\nvar templates = {};\n"
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
      output = @compilerLib.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName
    catch err
      error = err
    cb(error, output)
