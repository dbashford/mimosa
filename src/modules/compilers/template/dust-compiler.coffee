"use strict"

TemplateCompiler = require './template'

module.exports = class DustCompiler extends TemplateCompiler

  clientLibrary: "dust"
  handlesNamespacing: true
  libName: "dustjs-linkedin"

  @prettyName        = "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = ["dust"]

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      "define(['#{@libraryPath()}'], function (dust){ "
    else
      ""

  suffix: (config) ->
    if config.template.amdWrap
      'return dust; });'
    else
      ""

  compile: (file, cb) ->
    try
      output = @compilerLib.compile file.inputFileText, file.templateName
    catch err
      error = err
    cb(error, output)
