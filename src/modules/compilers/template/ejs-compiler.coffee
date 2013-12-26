"use strict"

compilerLib = null
libName = 'ejs'

setCompilerLib = (_compilerLib) ->
  compilerLib = _compilerLib

boilerplate = """
  var templates = {};
  var globalEscape = function(html){
    return String(html)
      .replace(/&(?!\w+;)/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  };
"""

prefix =  (config, libraryPath) ->
  if config.template.wrapType is 'amd'
    """
    define(['#{libraryPath}'], function (globalFilters){
      #{boilerplate}
    """
  else if config.template.wrapType is "common"
    """
      var globalFilters = require('#{config.template.commonLibPath}');
      #{boilerplate}
    """
  else
    boilerplate

suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = templates;"
  else
    ""

__transform = (output) ->
  output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;')

compile = (file, cb) ->
  unless compilerLib
    compilerLib = require libName

  try
    output = compilerLib.compile file.inputFileText,
      compileDebug: false,
      client: true,
      filename: file.inputFileName

    output = __transform(output + "")
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "ejs"
  compilerType: "template"
  defaultExtensions: ["ejs"]
  clientLibrary: "ejs-filters"
  compile: compile
  suffix: suffix
  prefix: prefix
  setCompilerLib: setCompilerLib

