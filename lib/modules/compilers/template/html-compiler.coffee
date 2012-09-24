fs = require 'fs'
path = require 'path'

_ = require 'underscore'

AbstractTemplateCompiler = require './template'
logger = require '../../../util/logger'

module.exports = class HTMLCompiler extends AbstractTemplateCompiler

  clientLibrary: null

  @prettyName        = "HTML - Just Plain HTML Snippets, no compiling"
  @defaultExtensions = ["template"]

  constructor: (config, @extensions) ->
    super(config)

  compile: (config, options, next) ->
    error = null

    # we don't want underscore to actually work, just to wrap stuff
    _.templateSettings =
      evaluate    : /<%%%%%%%%([\s\S]+?)%%%%%%%>/g,
      interpolate : /<%%%%%%%%=([\s\S]+?)%%%%%%%>/g

    output = "define(function () { var templates = {};\n"
    for templateName, templateData of options.templateContentByName
      fileName = templateData[0]
      content = templateData[1]
      logger.debug "Compiling HTML template [[ #{fileName} ]]"
      try
        compiledOutput = _.template(content)
        output += @addTemplateToOutput fileName, templateName, compiledOutput.source + "()"
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"

    # set it back
    _.templateSettings =
      evaluate    : /<%([\s\S]+?)%>/g,
      interpolate : /<%=([\s\S]+?)%>/g

    if error
      next({text:error})
    else
      options.output = output += 'return templates; });'
      next()