AbstractTemplateCompiler = require './template-compiler'
jade = require 'jade'
fs = require 'fs'
path = require 'path'

module.exports = class JadeCompiler extends AbstractTemplateCompiler

  constructor: (config) -> super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['#{@config.defineLocation}'], function (jade){ var templates = {};\n"
    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))

      try
        compiledOutput = jade.compile content,
          compileDebug: false,
          client: true,
          filename: fileName

        output += "templates['#{templateName}'] = #{compiledOutput};\n"
      catch err
        error += "#{err}\n"
    output += 'return templates; });'

    callback(error, output)