"use strict"

ejs = require 'ejs'

AbstractTemplateCompiler = require './template'

module.exports = class EJSCompiler extends AbstractTemplateCompiler

  clientLibrary: "ejs"

  @prettyName        = "EJS (Embedded JavaScript Templates) - http://jade-lang.com/"
  @defaultExtensions = ["ejs"]

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: ->
    "define(['#{@libraryPath()}'], function (ejs){ var templates = {};\n"

  amdSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      output = ejs.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName
    catch err
      error = err
    cb(error, output)
