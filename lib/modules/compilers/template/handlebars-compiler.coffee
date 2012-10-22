fs =         require 'fs'
path =       require 'path'

handlebars = require 'handlebars'
_ =          require 'lodash'
logger =     require 'mimosa-logger'

AbstractTemplateCompiler = require './template'

module.exports = class HandlebarsCompiler extends AbstractTemplateCompiler

  clientLibrary: "handlebars"

  @prettyName        = "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = ["hbs", "handlebars"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  amdPrefix: (config) =>
    logger.debug "Building Handlebars template file wrapper"
    jsDir = path.join config.watch.sourceDir, config.watch.javascriptDir
    possibleHelperPaths =
      for ext in config.extensions.javascript
        path.join(jsDir, "#{helperFile}.#{ext}") for helperFile in config.template.helperFiles
    helperPaths = _.flatten(possibleHelperPaths).filter((p) -> fs.existsSync(p))

    defines = ["'#{@libraryPath()}'"]
    for helperPath in helperPaths
      helperDefine = helperPath.replace(config.watch.sourceDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '')
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    logger.debug "Define string for Handlebars templates [[ #{defineString} ]]"

    """
    define([#{defineString}], function (Handlebars){

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

      if (!Handlebars) {
        console.log("Handlebars library has not been passed in successfully via require");
        return;
      }
      var template = Handlebars.template, templates = {};\n
    """

  amdSuffix: =>
    'return templates; });'

  compile: (file, templateName, cb) =>
    try
      compiledOutput = handlebars.precompile(file.inputFileText)
      compiledOutput = compiledOutput.replace("partials || Handlebars.partials;",
        "partials || Handlebars.partials; if (Object.keys(partials).length == 0) {partials = templates;}")
      output = "template(#{compiledOutput})"
    catch err
      error = err
    cb(error, output)
