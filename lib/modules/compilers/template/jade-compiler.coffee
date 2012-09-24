fs = require 'fs'
path = require 'path'

jade = require 'jade'

AbstractTemplateCompiler = require './template'
logger = require '../../../util/logger'

module.exports = class JadeCompiler extends AbstractTemplateCompiler

  clientLibrary: "jade-runtime"

  @prettyName        = "Jade - http://jade-lang.com/"
  @defaultExtensions = ["jade"]

  constructor: (config, @extensions) ->
    super(config)

  compile: (config, options, next) ->
    error = null

    output = "define(['#{@libraryPath()}'], function (jade){ var templates = {};\n"
    for templateName, templateData of options.templateContentByName
      fileName = templateData[0]
      content = templateData[1]
      logger.debug "Compiling Jade template [[ #{fileName} ]]"

      try
        compiledOutput = jade.compile content,
          compileDebug: false,
          client: true,
          filename: fileName

        output += @addTemplateToOutput fileName, templateName, compiledOutput
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"

    if error
      next({text:error})
    else
      options.output = output += 'return templates; });'
      next()