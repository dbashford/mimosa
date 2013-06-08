"use strict"

TemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends TemplateCompiler

  constructor: (config) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(['#{@libraryPath()}'], function (_) { var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, cb) =>
    try
      compiledOutput = @getLibrary().template(file.inputFileText)
      output = compiledOutput.source
    catch err
      error = err
    cb(error, output)
