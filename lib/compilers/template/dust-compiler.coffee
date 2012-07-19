fs = require 'fs'
path = require 'path'

dust = require 'dustjs-linkedin'

AbstractTemplateCompiler = require './template'

module.exports = class DustCompiler extends AbstractTemplateCompiler

  clientLibrary: "dust"

  @prettyName        = -> "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = -> ["dust"]

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['#{@clientLibrary}'], function (dust){ "
    for fileName in fileNames
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename fileName, path.extname(fileName)
      try
        output += dust.compile content, templateName
      catch err
        error += "#{err}\n"
    output += 'return dust; });'

    callback(error, output)