"use strict"

fs =     require 'fs'
path =   require 'path'

logger = require 'logmimosa'

handlebars = null
ember = false
config = {}
compiler = null

regularBoilerplate =
  """
  if (!Handlebars) {
    console.log("Handlebars library has not been passed in successfully");
    return;
  }

  if (!Object.keys) {
     Object.keys = function (obj) {
         var keys = [],
             k;
         for (k in obj) {
             if (Object.prototype.hasOwnProperty.call(obj, k)) {
                 keys.push(k);
             }
         }
         return keys;
     };
  }

  var template = Handlebars.template, templates = {};
  Handlebars.partials = templates;\n
  """

emberBoilerplate =
  """
  var template = Ember.Handlebars.template, templates = {};\n
  """

__determineHandlebars = ->
  ember = config.template.handlebars.ember.enabled
  hbs = if config.compilers.libs.handlebars
    config.compilers.libs.handlebars
  else
    require 'handlebars'

  handlebars = if ember
    ec = require './resources/ember-comp'
    ec.makeHandlebars hbs
  else
    hbs

prefix = (config, libraryPath) ->

  boilerplate = if ember
    emberBoilerplate
  else
    regularBoilerplate

  if config.template.wrapType is 'amd'
    logger.debug "Building Handlebars template file wrapper"
    jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
    possibleHelperPaths = []
    for ext in config.extensions.javascript
      for helperFile in config.template.handlebars.helpers
        possibleHelperPaths.push path.join(jsDir, "#{helperFile}.#{ext}")
    helperPaths = possibleHelperPaths.filter (p) -> fs.existsSync(p)

    {defines, params} = if ember
      {defines:["'#{config.template.handlebars.ember.path}'"], params:["Ember"]}
    else
      {defines:["'#{libraryPath}'"], params:["Handlebars"]}

    for helperPath in helperPaths
      helperDefine = helperPath.replace(config.watch.sourceDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '')
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    logger.debug "Define string for Handlebars templates [[ #{defineString} ]]"

    """
    define([#{defineString}], function (#{params.join(',')}){
      #{boilerplate}
    """
  else if config.template.wrapType is 'common'
    if ember
      """
      var Ember = require('#{config.template.commonLibPath}');
      #{boilerplate}
      """
    else
      """
      var Handlebars = require('#{config.template.commonLibPath}');
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

init = (conf) ->
  config = conf

compile = (file, cb) ->
  unless handlebars
    __determineHandlebars()

  try
    output = handlebars.precompile file.inputFileText
    output = "template(#{output.toString()})"
    if ember
      output = "Ember.TEMPLATES['#{file.templateName}'] = #{output}"
  catch err
    error = err
  cb(error, output)

module.exports =
  base: "handlebars"
  type: "template"
  defaultExtensions: ["hbs", "handlebars"]
  clientLibrary: "handlebars"
  compile: compile
  init: init
  suffix: suffix
  prefix: prefix