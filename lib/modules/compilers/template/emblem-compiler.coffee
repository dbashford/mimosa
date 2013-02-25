"use strict"

emblem =     require 'emblem'
logger =     require 'logmimosa'

HandlebarsCompiler = require './handlebars'

module.exports = class EmblemCompiler extends HandlebarsCompiler

  @prettyName        = "Emblem - http://emblemjs.com/"
  @defaultExtensions = ["emblem", "embl"]

  constructor: (config, @extensions) ->
    super(config)

    if @ember
      emblem.handlebarsVariant = require 'handlebars'

  compile: (file, templateName, cb) =>
    if @ember
      try
        ast = emblem.parse file.inputFileText
      catch err
        return cb(err, output)

      @handlebars.precompile ast, {}, (error, out) =>
        unless error
          output = @transformTemplate out
          output = "Ember.TEMPLATES['#{templateName}'] = #{output}"
        cb(error, output)
    else
      try
        output = emblem.precompile @handlebars, file.inputFileText
        output = @transformTemplate output
      catch err
        error = err
      cb(error, output)