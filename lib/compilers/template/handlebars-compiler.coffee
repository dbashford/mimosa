fs =         require 'fs'
path =       require 'path'

handlebars = require 'handlebars'
_ =          require 'lodash'

AbstractTemplateCompiler = require './template'

module.exports = class HandlebarsCompiler extends AbstractTemplateCompiler

  clientLibrary: "handlebars"

  @prettyName        = -> "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = -> ["hbs", "handlebars"]

  constructor: (config) ->
    super(config)
    @_buildOutputStart()

  _buildOutputStart: =>
    possibleHelperPaths =
      for ext in @fullConfig.compilers.javascript.extensions
        path.join(@srcDir, "#{helperFile}.#{ext}") for helperFile in @config.helperFiles
    helperPaths = _.flatten(possibleHelperPaths).filter((p) -> fs.existsSync(p))

    defines = ["'vendor/#{@clientLibrary}'"]
    for helperPath in helperPaths
      helperDefine = helperPath.replace(@srcDir, "").replace(/(^[\\\/]?[A-Za-z]+[\\\/])/, '').replace(/\.\w+$/,"")
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    @outputStart = """
             define([#{defineString}], function (Handlebars){
               if (!Handlebars) {
                 console.log("Handlebars library has not been passed in successfully via require");
                 return;
               }
               var template = Handlebars.template, templates = {};\n
             """

  compile: (fileNames, callback) ->
    error = null

    output = @outputStart

    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename fileName, path.extname(fileName)
      try
        compiledOutput = handlebars.precompile(content)
        output += @addTemplateToOutput(fileName, templateName, "template(#{compiledOutput})")
      catch err
        error ?= ''
        error += "#{fileName}, #{err} \n"

    output += 'return templates; });'

    callback(error, output)