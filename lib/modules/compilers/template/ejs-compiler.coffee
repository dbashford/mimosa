"use strict"

ejs = require 'ejs'

TemplateCompiler = require './template'

module.exports = class EJSCompiler extends TemplateCompiler

  clientLibrary: "ejs-filters"

  @prettyName        = "Embedded JavaScript Templates (EJS) - https://github.com/visionmedia/ejs"
  @defaultExtensions = ["ejs"]

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: ->
    """
    define(['#{@libraryPath()}'], function (globalFilters){
    var templates = {};
    var globalEscape = function(html){
      return String(html)
        .replace(/&(?!\w+;)/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    };
    """

  amdSuffix: ->
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      output = ejs.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName

      output = @transform(output + "")
    catch err
      error = err
    cb(error, output)

  transform: (output) =>
    output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;')
