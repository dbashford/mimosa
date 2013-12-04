"use strict"

HandlebarsCompiler = require './handlebars'

module.exports = class EmblemCompiler extends HandlebarsCompiler
  libName: "emblem"

  @defaultExtensions = ["emblem", "embl"]

  constructor: (@mimosaConfig, @extensions) ->
    super(@mimosaConfig)

  compile: (file, cb) =>
    # make sure handlebars determined
    @determineHandlebars @mimosaConfig unless @handlebars

    try
      output = @compilerLib.precompile @handlebars, file.inputFileText
      output = @transformTemplate output.toString()
      if @ember
        output = "Ember.TEMPLATES['#{file.templateName}'] = #{output}"
    catch err
      error = err
    cb(error, output)