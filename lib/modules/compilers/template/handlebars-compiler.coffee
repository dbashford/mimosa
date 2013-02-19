"use strict"

fs =         require 'fs'
path =       require 'path'

handlebars = null
_ =          require 'lodash'
logger =     require 'logmimosa'

TemplateCompiler = require './template'

module.exports = class HandlebarsCompiler extends TemplateCompiler

  @prettyName        = "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = ["hbs", "handlebars"]
  @isDefault         = true

  clientLibrary: "handlebars"

  boilerplate:
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

    var template = Handlebars.template, templates = {};\n
    """

  emberBoilerplate:
    """
    var template = Ember.Handlebars.template, templates = {};\n
    """

  boilerplate: =>
    if @ember
      @emberBoilerplate
    else
      @regularBoilerplate

  constructor: (config, @extensions) ->
    super(config)

    @ember = config.template.handlebars.ember.enabled
    handlebars = if @ember
      @clientLibrary = null
      require 'ember-precompile'
    else
      require 'handlebars'

  prefix: (config) =>
    if config.template.amdWrap
      logger.debug "Building Handlebars template file wrapper"
      jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
      possibleHelperPaths = []
      for ext in config.extensions.javascript
        for helperFile in config.template.handlebars.helpers
          possibleHelperPaths.push path.join(jsDir, "#{helperFile}.#{ext}")
      helperPaths = possibleHelperPaths.filter (p) -> fs.existsSync(p)

      {defines, params} = if @ember
        {defines:["'#{config.template.handlebars.ember.path}'"], params:["Ember"]}
      else
        {defines:["'#{@libraryPath()}'"], params:["Handlebars"]}

      for helperPath in helperPaths
        helperDefine = helperPath.replace(config.watch.sourceDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '')
        defines.push "'#{helperDefine}'"
      defineString = defines.join ','

      logger.debug "Define string for Handlebars templates [[ #{defineString} ]]"

      """
      define([#{defineString}], function (#{params.join(',')}){
        #{@boilerplate()}
      """
    else
      @boilerplate()

  suffix: (config) ->
    if config.template.amdWrap
      'return templates; });'
    else
      ""

  compile: (file, templateName, cb) =>
    try
      output = if @ember
        out = handlebars file.inputFileName
        "Ember.TEMPLATES['#{templateName}'] = #{out}"
      else
        out = handlebars.precompile file.inputFileText
        out = out.replace("partials || Handlebars.partials;",
          "partials || Handlebars.partials; if (Object.keys(partials).length == 0) {partials = templates;}")
        out += "template(#{compiledOutput})"
        out

    catch err
      error = err
    cb(error, output)
