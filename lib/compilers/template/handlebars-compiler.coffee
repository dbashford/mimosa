AbstractTemplateCompiler = require './template'
handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'

module.exports = class HandlebarsCompiler extends AbstractTemplateCompiler

  clientLibrary: "handlebars"

  @prettyName        = -> "Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = -> ["hbs", "handlebars"]

  constructor: (config) -> super(config)

  compile: (fileNames, callback) ->
    error = null

    possibleHelperPaths =
      for ext in @fullConfig.compilers.javascript.extensions
        path.join(@srcDir, "#{helperFile}.#{ext}") for helperFile in @config.helperFiles
    helperPaths = possibleHelperPaths.flatten().filter((p) -> fs.existsSync(p))

    defines = ["'#{@clientLibrary}'"]
    for helperPath in helperPaths
      helperDefine = helperPath.replace(@srcDir, "").replace(/(^[\\\/]?[A-Za-z]+[\\\/])/, '').replace(/\.\w+$/,"")
      defines.push "'#{helperDefine}'"
    defineString = defines.join ','

    output = """
             define([#{defineString}], function (Handlebars){
               if (!Handlebars) {
                 console.log("Handlebars library has not been passed in successfully via require");
                 return;
               }
               var template = Handlebars.template, templates = {};\n
             """

    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))
      try
        templateOutput = handlebars.precompile(content)
        output += "templates['#{templateName}'] = template(#{templateOutput});\n"
      catch err
        error += "#{err} \n"

    output += 'return templates; });'

    callback(error, output)