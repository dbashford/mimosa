"use strict"

TemplateCompiler = require './template'

module.exports = class EJSCompiler extends TemplateCompiler

  clientLibrary: "ejs-filters"
  libName: "ejs"

  @prettyName        = "Embedded JavaScript Templates (EJS) - https://github.com/visionmedia/ejs"
  @defaultExtensions = ["ejs"]

  boilerplate: """
    var templates = {};
    var globalEscape = function(html){
      return String(html)
        .replace(/&(?!\w+;)/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;');
    };
  """

  constructor: (config, @extensions) ->
    super(config)

  prefix: (config) ->
    if config.template.amdWrap
      """
      define(['#{@libraryPath()}'], function (globalFilters){
        #{@boilerplate}
      """
    else
      @boilerplate


  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, cb) =>
    try
      output = @compilerLib.compile file.inputFileText,
        compileDebug: false,
        client: true,
        filename: file.inputFileName

      output = @transform(output + "")
    catch err
      error = err
    cb(error, output)

  transform: (output) =>
    output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;')
