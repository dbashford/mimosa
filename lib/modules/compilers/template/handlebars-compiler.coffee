"use strict"

logger =     require 'logmimosa'

HandlebarsCompiler = require './handlebars'

module.exports = class HBSCompiler extends HandlebarsCompiler

  @prettyName        = "(*) Handlebars - http://handlebarsjs.com/"
  @defaultExtensions = ["hbs", "handlebars"]
  @isDefault         = true

  constructor: (config, @extensions) ->
    super(config)

  compile: (file, templateName, cb) =>
    if @ember
      @handlebars.precompile file.inputFileText, {}, (error, out) =>
        unless error
          output = @transformTemplate out
          output = "Ember.TEMPLATES['#{templateName}'] = #{output}"
        cb(error, output)
    else
      try
        output = @handlebars.precompile file.inputFileText
        output = @transformTemplate output
      catch err
        error = err
      cb(error, output)