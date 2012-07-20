fs = require 'fs'
path = require 'path'

AbstractTemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['vendor/#{@clientLibrary}'], function () { var templates = {};\n"
    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))
      try
        compiledOutput = @getLibrary().template(content)
        output += "templates['#{templateName}'] = #{compiledOutput.source};\n"
      catch err
        error += "#{err}\n"
    output += 'return templates; });'

    callback(error, output)