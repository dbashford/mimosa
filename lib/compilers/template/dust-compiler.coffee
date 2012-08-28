fs = require 'fs'
path = require 'path'

dust = require 'dustjs-linkedin'

AbstractTemplateCompiler = require './template'
logger = require '../../util/logger'

module.exports = class DustCompiler extends AbstractTemplateCompiler

  clientLibrary: "dust"

  @prettyName        = "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = ["dust"]

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['vendor/#{@clientLibrary}'], function (dust){ "
    for fileName in fileNames
      logger.debug "Compiling Dust template [[ #{fileName} ]]"
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename fileName, path.extname(fileName)
      try
        output += @templatePreamble fileName, templateName
        output += dust.compile content, templateName
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"
    output += 'return dust; });'

    callback(error, output)