fs = require 'fs'
path = require 'path'

hogan = require "hogan.js"

AbstractTemplateCompiler = require './template'
logger = require '../../util/logger'

module.exports = class HoganCompiler extends AbstractTemplateCompiler

  clientLibrary: "hogan-template"

  @prettyName        = "Hogan - http://twitter.github.com/hogan.js/"
  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config) ->
    super(config)

  compile: (fileNames, callback) ->
    error = null

    output = "define(['vendor/#{@clientLibrary}'], function (Hogan){ var templates = {};\n"
    for fileName in fileNames
      logger.debug "Compiling Hogan template [[ #{fileName} ]]"
      content = fs.readFileSync fileName, "ascii"
      templateName = path.basename(fileName, path.extname(fileName))

      try
        compiledOutput = hogan.compile(content, {asString:true})
        output += @addTemplateToOutput fileName, templateName, "new Hogan.Template(#{compiledOutput})"
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"
    output += 'return templates; });'

    callback(error, output)