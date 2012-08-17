fs = require 'fs'
path = require 'path'

jade = require 'jade'

AbstractTemplateCompiler = require './template'
logger = require '../../util/logger'

module.exports = class JadeCompiler extends AbstractTemplateCompiler

  clientLibrary: "jade-runtime"

  @prettyName        = -> "Jade - http://jade-lang.com/"
  @defaultExtensions = -> ["jade"]

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['vendor/#{@clientLibrary}'], function (jade){ var templates = {};\n"
    for fileName in fileNames
      logger.debug "Compiling Jade template [[ #{fileName} ]]"

      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))

      try
        compiledOutput = jade.compile content,
          compileDebug: false,
          client: true,
          filename: fileName

        output += @addTemplateToOutput fileName, templateName, compiledOutput
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"
    output += 'return templates; });'

    callback(error, output)