"use strict"

logger =     require 'logmimosa'

HandlebarsCompiler = require './handlebars'

module.exports = class HBSCompiler extends HandlebarsCompiler

  @prettyName        = "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = ["hbs", "handlebars"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  compile: (file, cb) =>
    try
      output = @handlebars.precompile file.inputFileText
      output = @transformTemplate output.toString()
      if @ember
        output = "Ember.TEMPLATES['#{file.templateName}'] = #{output}"
    catch err
      error = err
    cb(error, output)