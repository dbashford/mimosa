"use strict"

hogan = require "hogan.js"

AbstractTemplateCompiler = require './template'

module.exports = class HoganCompiler extends AbstractTemplateCompiler

  clientLibrary: "hogan-template"

  @prettyName        = "Hogan - http://twitter.github.com/hogan.js/"
  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: ->
    "define(['#{@libraryPath()}'], function (Hogan){ var templates = {};\n"

  amdSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) ->
    try
      compiledOutput = hogan.compile(file.inputFileText, {asString:true})
      output = "templates['#{templateName}'] = new Hogan.Template(#{compiledOutput});\n"
    catch err
      error = err
    cb(error, output)
