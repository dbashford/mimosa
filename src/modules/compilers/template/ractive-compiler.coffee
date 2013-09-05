"use strict"

TemplateCompiler = require './template'

module.exports = class RactiveCompiler extends TemplateCompiler

  clientLibrary: 'ractive'
  libName: 'ractive'

  @prettyName        = "Ractive - http://www.ractivejs.org/"
  @defaultExtensions = ["rtv","rac"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.wrapType is 'amd'
      "define(['#{@libraryPath()}'], function (){ var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.wrapType is 'amd'
      'return templates; });'
    else if config.template.wrapType is "common"
      "module.exports = templates;"
    else
      ""

  compile: (file, cb) ->
    try
      output = @compilerLib.parse file.inputFileText
      output = JSON.stringify output
    catch err
      error = err
    cb(error, output)
