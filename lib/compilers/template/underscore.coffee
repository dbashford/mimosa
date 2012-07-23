fs = require 'fs'
path = require 'path'

AbstractTemplateCompiler = require './template'

module.exports = class AbstractUnderscoreCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['vendor/#{@clientLibrary}'], function (_) { var templates = {};\n"
    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))
      try
        compiledOutput = @getLibrary().template(content)
        output += @addTemplateToOutput fileName, templateName, compiledOutput.source
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"
    output += 'return templates; });'

    callback(error, output)