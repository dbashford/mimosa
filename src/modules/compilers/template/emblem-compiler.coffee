"use strict"

HandlebarsCompiler = require './handlebars'

module.exports = class EmblemCompiler extends HandlebarsCompiler

  @prettyName        = "Emblem - http://emblemjs.com/"
  @defaultExtensions = ["emblem", "embl"]

  constructor: (config, @extensions) ->
    super(config)

    @emblem = if config.template.emblem?.lib?
      config.template.emblem.lib
    else
      require 'emblem'

  compile: (file, cb) =>
    try
      output = @emblem.precompile @handlebars, file.inputFileText
      output = @transformTemplate output.toString()
      if @ember
        output = "Ember.TEMPLATES['#{file.templateName}'] = #{output}"
    catch err
      error = err
    cb(error, output)