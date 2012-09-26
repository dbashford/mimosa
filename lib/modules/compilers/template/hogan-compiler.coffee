fs = require 'fs'
path = require 'path'

hogan = require "hogan.js"

AbstractTemplateCompiler = require './template'
logger = require '../../../util/logger'

module.exports = class HoganCompiler extends AbstractTemplateCompiler

  clientLibrary: "hogan-template"

  @prettyName        = "Hogan - http://twitter.github.com/hogan.js/"
  @defaultExtensions = ["hog", "hogan", "hjs"]

  constructor: (config, @extensions) ->
    super(config)

  compile: (config, options, next) =>
    error = null

    output = "define(['#{@libraryPath()}'], function (Hogan){ var templates = {};\n"
    for templateName, templateData of options.templateContentByName
      fileName = templateData[0]
      content = templateData[1]
      logger.debug "Compiling Hogan template [[ #{fileName} ]]"
      try
        compiledOutput = hogan.compile(content, {asString:true})
        output += @addTemplateToOutput fileName, templateName, "new Hogan.Template(#{compiledOutput})"
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"

    if error
      next({text:error})
    else
      options.output = output += 'return templates; });'
      next()