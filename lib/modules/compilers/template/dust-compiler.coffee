fs = require 'fs'
path = require 'path'

dust = require 'dustjs-linkedin'

AbstractTemplateCompiler = require './template'
logger = require '../../../util/logger'

module.exports = class DustCompiler extends AbstractTemplateCompiler

  clientLibrary: "dust"

  @prettyName        = "(*) Dust - https://github.com/linkedin/dustjs/"
  @defaultExtensions = ["dust"]

  constructor: (config, @extensions) ->
    super(config)

  compile: (config, options, next) =>
    console.log "INSIDE DUST COMPILE"
    console.log options.templateContentByName

    error = null

    output = "define(['#{@libraryPath()}'], function (dust){ "
    for templateName, templateData of options.templateContentByName

      fileName = templateData[0]
      content = templateData[1]
      logger.debug "Compiling Dust template [[ #{fileName} ]]"
      try
        output += @templatePreamble fileName, templateName
        output += dust.compile content, templateName
      catch err
        error ?= ''
        error += "#{fileName}, #{err}\n"

    if error
      next({text:error})
    else
      options.output = output += 'return dust; });'
      next()