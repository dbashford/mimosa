"use strict"

dust = require 'dustjs-linkedin'

TemplateCompiler = require './template'

module.exports = class DustCompiler extends TemplateCompiler

  clientLibrary: "dust"
  handlesNamespacing: true

  @prettyName        = "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = ["dust"]

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: ->
    "define(['#{@libraryPath()}'], function (dust){ "

  amdSuffix: ->
    'return dust; });'

  compile: (file, templateName, cb) ->
    try
      output = dust.compile file.inputFileText, templateName
    catch err
      error = err
    cb(error, output)
