"use strict"

logger = require 'logmimosa'

_compile = (config, options, next) ->
  hasFiles = options.files?.length > 0
  return next() unless hasFiles

  options.files.forEach (file) ->
    if config.copy?.excludeRegex? and file.inputFileName.match config.copy.excludeRegex
      logger.debug "skipping copy file [[ #{file.inputFileName} ]], file is excluded via regex"
    else if config.copy.exclude.indexOf(file.inputFileName) > -1
      logger.debug "skipping copy file [[ #{file.inputFileName} ]], file is excluded via string path"
    else
      file.outputFileText = file.inputFileText

  next()

compiler = class CopyCompiler

  constructor: (config, @extensions) ->

  registration: (config, register) ->
    register ['add','update','buildFile'], 'compile', _compile, @extensions

module.exports =
  compiler: compiler
  base: "copy"
  type: "copy"
