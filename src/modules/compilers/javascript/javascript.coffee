"use strict"

path = require 'path'
fs = require 'fs'

_ = require "lodash"
logger = require 'logmimosa'

fileUtils = require '../../../util/file'

_genMapFileName = (config, file) ->
  extName = path.extname file.inputFileName
  file.inputFileName.replace(extName, ".js.map").replace(config.watch.sourceDir, config.watch.compiledDir)

_genSourceName = (config, file) ->
  file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src"

_cleanUpSourceMaps = (config, options, next) ->
  i = 0
  done = -> next() if ++i is 2

  options.files.forEach (file) =>
    mapFileName = _genMapFileName(config, file)
    sourceName = _genSourceName(config, file)
    [mapFileName, sourceName].forEach (f) ->
      fs.exists f, (exists) =>
        if exists
          fs.unlink f, (err) ->
            if err
              logger.error "Error deleting file [[ #{f} ]], #{err}"
            else
              logger.debug "Deleted file [[ #{f} ]]"
            done()
        else
          done()

_cleanUpSourceMapsRegister = (register, extensions, compilerConfig) ->
  # register remove only if sourcemap as remove is watch workflow
  if compilerConfig.sourceMap
    register ['remove'], 'delete', _cleanUpSourceMaps, extensions

  # register clean regardless to ensure any existing source maps are removed during build/clean
  register ['cleanFile'], 'delete', _cleanUpSourceMaps, extensions


module.exports = class JSCompiler

  constructor: (config, @extensions, @compiler) ->
    if @compiler.init
      @compiler.init(config, @extensions)

  registration: (config, register) ->
    register ['add','update','buildFile'], 'compile', @_compile, @extensions

    if @compiler.cleanUpSourceMaps
      _cleanUpSourceMapsRegister register, @extensions, @compiler.config ? {}

  _compile: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles

    i = 0
    newFiles = []

    whenDone = options.files.length
    done = ->
      if ++i is whenDone
        options.files = newFiles
        next()

    options.files.forEach (file) =>

      if logger.isDebug
        logger.debug "Calling compiler function for compiler [[ " + @compiler.base + " ]]"

      @compiler.compile file, (err, output, compiledConfig, sourceMap) =>
        if err
          logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}", {exitIfBuild:true}
        else
          if sourceMap

            if compiledConfig.sourceMapDynamic
              sourceMap = JSON.parse(sourceMap)
              sourceMap.sources[0] = file.inputFileName
              sourceMap.sourcesContent = [file.inputFileText];
              sourceMap.file = file.outputFileName;

              base64SourceMap = new Buffer(JSON.stringify(sourceMap)).toString('base64')
              datauri = 'data:application/json;base64,' + base64SourceMap
              output = "#{output}\n//@ sourceMappingURL=#{datauri}\n"

            else
              whenDone += 2
              # writing source
              sourceName = _genSourceName(config, file)
              fileUtils.writeFile sourceName, file.inputFileText, (err) ->
                if err
                  logger.error "Error writing source file [[ #{sourceName} ]], #{err}"
                done()

              # writing map
              file.sourceMap = sourceMap
              file.sourceMapName = _genMapFileName(config, file)
              fileUtils.writeFile file.sourceMapName, sourceMap, (err) ->
                if err
                  logger.error "Error writing map file [[ #{file.sourceMapName} ]], #{err}"
                done()

              # @ is deprecated but # not widely supported in current release browsers
              # output = "#{output}\n/*\n//# sourceMappingURL=#{path.basename(file.sourceMapName)}\n*/\n"
              output = "#{output}\n/*\n//@ sourceMappingURL=#{path.basename(file.sourceMapName)}\n*/\n"

          file.outputFileText = output
          newFiles.push file

        done()