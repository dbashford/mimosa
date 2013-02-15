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

  compile: (file, templateName, cb) ->
    try
      output = dust.compile file.inputFileText, templateName
    catch err
      error = err
    cb(error, output)
