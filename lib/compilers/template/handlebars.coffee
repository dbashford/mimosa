AbstractTemplateCompiler = require './template-compiler'
handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'

module.exports = class HandlebarsCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)
    @extensions =     config?.extensions     || ["hbs", "handlebars"]
    @defineLocation = config?.defineLocation || 'vendor/handlebars'
    @helperFile =     config?.helperFile     || "javascripts/handlebars-helpers"

  compile: (fileNames, callback) ->
    error = null

    helperPath = path.join(@destDir, @helperFile + ".js")
    defines = ["'#{@defineLocation}'"]
    if path.existsSync(helperPath)
      helperDefine = @helperFile.replace /(^[\\\/]?[A-Za-z]+[\\\/])/, ''
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    output = """
             define([#{defineString}], function (Handlebars){
               if (!Handlebars) {
                 console.log("Handlebars library has not been passed in successfully via require");
                 return;
               }
               var template = Handlebars.template, templates = {};
             """

    output += for fileName in fileNames
      out = ''
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))
      try
        templateOutput = handlebars.precompile(content)
        out = "  templates['#{templateName}'] = template(#{templateOutput});\n"
      catch err
        error += "#{err} \n"
      out

    output += 'return templates; });'

    callback(error, output)