"use strict"

_compilerLib = null

_prefix = (config, libraryPath) ->
  if config.template.wrapType is "amd"
    "define(['#{libraryPath}'], function (dust){ "
  else if config.template.wrapType is "common"
    "var dust = require('#{config.template.commonLibPath}');\n"
  else
    ""

_suffix = (config) ->
  if config.template.wrapType is "amd"
    'return dust; });'
  else if config.template.wrapType is "common"
    "\nmodule.exports = dust;"
  else
    ""

_compile = (file, cb) ->
  try
    output = _compilerLib.compile file.inputFileText, file.templateName
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "dust"
  type: "template"
  defaultExtensions: ["dust"]
  libName: 'dustjs-linkedin'
  clientLibrary: "dust"
  handlesNamespacing: true
  compile: _compile
  suffix: _suffix
  prefix: _prefix
  compilerLib: _compilerLib