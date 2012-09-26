fs = require 'fs'
path = require 'path'

AbstractTemplateCompiler = require './template'
logger = require '../../../util/logger'

module.exports = class AbstractUnderscoreCompiler extends AbstractTemplateCompiler

  constructor: (config) ->
    super(config)

  compile: (config, options, next) =>
    error = null

    output = "define(['#{@libraryPath()}'], function (_) { var templates = {};\n"
    for templateName, templateData of options.templateContentByName
      fileName = templateData[0]
      content = templateData[1]
      logger.debug "Compiling #{@clientLibrary} template [[ #{fileName} ]]"
      try
        compiledOutput = @getLibrary().template(content)
        output += @addTemplateToOutput fileName, templateName, compiledOutput.source
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"

    if error
      next({text:error})
    else
      options.output = output += 'return templates; });'
      next()