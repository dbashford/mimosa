"use strict"

emblem =     require 'emblem'
logger =     require 'logmimosa'

HandlebarsCompiler = require './handlebars'

module.exports = class EmblemCompiler extends HandlebarsCompiler

  @prettyName        = "Emblem - http://emblemjs.com/"
  @defaultExtensions = ["emblem", "embl"]

  constructor: (config, @extensions) ->
    super(config)

  compile: (file, cb) =>
    try
      output = emblem.precompile @handlebars, file.inputFileText
      output = @transformTemplate output.toString()
      if @ember
        output = "Ember.TEMPLATES['#{file.templateName}'] = #{output}"
    catch err
      error = err
    cb(error, output)