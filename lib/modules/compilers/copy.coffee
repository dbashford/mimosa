"use strict"

module.exports = class CopyCompiler

  constructor: (config, @extensions) ->

  registration: (config, register) ->
    register ['add','update','buildFile'], 'compile', @compile, @extensions

  compile: (config, options, next) ->
    return next() unless options.files?.length > 0
    options.files.forEach (file) =>
      file.outputFileText = file.inputFileText

    next()