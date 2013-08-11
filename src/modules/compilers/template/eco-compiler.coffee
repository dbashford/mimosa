"use strict"

TemplateCompiler = require './template'

module.exports = class EcoCompiler extends TemplateCompiler

  clientLibrary: null
  libName: 'eco'

  @prettyName        = "Embedded CoffeeScript Templates (ECO) - https://github.com/sstephenson/eco"
  @defaultExtensions = ["eco"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(function (){ var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, cb) ->
    try
      output = @compilerLib.precompile file.inputFileText
    catch err
      error = err
    cb(error, output)
