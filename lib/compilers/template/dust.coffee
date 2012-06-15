AbstractTemplateCompiler = require './template-compiler'
dust = require 'dustjs-linkedin'
fs = require 'fs'
path = require 'path'

module.exports = class DustCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)
    @extensions =     config?.extensions     || ["dust"]
    @defineLocation = config?.defineLocation || 'vendor/dust'

  compile: (fileNames, callback) ->
    error = null

    output = "define(['#{@defineLocation}'], function (dust){ "
    output += for fileName in fileNames
      out = ''
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))
      try
        out = dust.compile(content, templateName)
      catch err
        error += "#{err}\n"
      out
    output += 'return dust; });'

    callback(error, output)