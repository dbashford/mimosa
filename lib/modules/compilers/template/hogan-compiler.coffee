"use strict"

hogan = require "hogan.js"

TemplateCompiler = require './template'

module.exports = class HoganCompiler extends TemplateCompiler

  clientLibrary: "hogan-template"

  @prettyName        = "Hogan - http://twitter.github.com/hogan.js/"
  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(['#{@libraryPath()}'], function (Hogan){ var templates = {};\n"
    else
      "var templates = {};\n"

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, templateName, cb) ->
    try
      compiledOutput = hogan.compile(file.inputFileText, {asString:true})
      output = "templates['#{templateName}'] = new Hogan.Template(#{compiledOutput});\n"
    catch err
      error = err
    cb(error, output)
