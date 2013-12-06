"use strict"

_compilerLib = null

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

_prefix =  (config, libraryPath) ->
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

_suffix = (config) ->
  if config.template.wrapType is 'amd'
    'return templates; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = templates;"
  else
    ""

__transform = (output) ->
  output.replace(/\nescape[\s\S]*?};/, 'escape = escape || globalEscape; filters = filters || globalFilters;')

_compile = (file, cb) ->
  try
    output = _compilerLib.compile file.inputFileText,
      compileDebug: false,
      client: true,
      filename: file.inputFileName

    output = __transform(output + "")
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "ejs"
  type: "template"
  defaultExtensions: ["ejs"]
  libName: 'ejs'
  clientLibrary: "ejs-filters"
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib

