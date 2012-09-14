fs =         require 'fs'
path =       require 'path'

handlebars = require 'handlebars'
_ =          require 'lodash'

AbstractTemplateCompiler = require './template'
logger = require '../../util/logger'

module.exports = class HandlebarsCompiler extends AbstractTemplateCompiler

  clientLibrary: "handlebars"

  @prettyName        = "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = ["hbs", "handlebars"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  _buildOutputStart: =>
    logger.debug "Building Handlebars template file wrapper"
    possibleHelperPaths =
      for ext in @fullConfig.javascriptExtensions
        path.join(@srcDir, "#{helperFile}.#{ext}") for helperFile in @fullConfig.template.helperFiles
    helperPaths = _.flatten(possibleHelperPaths).filter((p) -> fs.existsSync(p))

    defines = ["'#{@libraryPath()}'"]
    for helperPath in helperPaths
      helperDefine = helperPath.replace(@srcDir, '').replace(/\\/g, '/').replace(/^\/?\w+\/|\.\w+$/g, '')
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    logger.debug "Define string for Handlebars templates [[ #{defineString} ]]"

    @outputStart = """
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

  compile: (fileNames, callback) ->
    error = null

    output = @_buildOutputStart()

    for fileName in fileNames
      logger.debug "Compiling Handlebars template [[ #{fileName} ]]"
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename fileName, path.extname(fileName)
      try
        compiledOutput = handlebars.precompile(content)
        compiledOutput = compiledOutput.replace("partials || Handlebars.partials;",
          "partials || Handlebars.partials; if (Object.keys(partials).length == 0) {partials = templates;}")
        output += @addTemplateToOutput(fileName, templateName, "template(#{compiledOutput})")
      catch err
        error ?= ''
        error += "#{fileName}, #{err} \n"

    output += 'return templates; });'

    callback(error, output)