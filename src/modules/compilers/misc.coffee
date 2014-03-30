"use strict"

logger = require 'logmimosa'

module.exports = class MiscCompiler

  constructor: (config, @compiler) ->
    @extensions = @compiler.extensions(config)

  registration: (config, register) ->

    register(
      ['add','update','remove','cleanFile','buildFile'],
      'init',
      @_determineOutputFile,
      @extensions)

    register(
      ['add','update','buildFile'],
      'compile',
      @compiler.compile,
      @extensions)

  _determineOutputFile: (config, options, next) =>
    if options.files and options.files.length
      if @compiler.compilerType is "copy"
        options.destinationFile = (fileName) ->
          fileName.replace(config.watch.sourceDir, config.watch.compiledDir)

        options.files.forEach (file) ->
          file.outputFileName = options.destinationFile( file.inputFileName )
        next()
      else
        if @compiler.determineOutputFile
          @compiler.determineOutputFile( config, options, next )
        else
          if logger.isDebug()
            logger.debug "compiler [[ " + @compiler.name + " ]] does not have determineOutputFile function."
          next()
    else
      next()