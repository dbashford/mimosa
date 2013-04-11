"use strict"

path = require 'path'
fs = require 'fs'
fileUtils = require '../../../util/file'

logger = require 'logmimosa'

module.exports = class JSCompiler

  registration: (config, register) ->
    register ['add','update','buildFile'], 'compile', @_compile, @extensions

  _compile: (config, options, next) =>
    i = 0
    newFiles = []

    options.files.forEach (file) =>
      @compile file, (err, output, sourceMap) =>
        if err
          logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}"
        else
          if config.isVirgin
            logger.success "Compiled/copied [[ #{file.outputFileName} ]]", options

          if sourceMap
            mapFileName = @_genMapFileName(config, file)
            fileUtils.writeFile mapFileName, sourceMap, (err) ->
              if err
                logger.error "Error writing map file [[ #{mapFileName} ]], #{err}"

            sourceName = @_genSourceName(config, file)
            fileUtils.writeFile sourceName, file.inputFileText, (err) ->
              if err
                logger.error "Error writing source file [[ #{sourceName} ]], #{err}"

            output = "#{output}\n/*\n//@ sourceMappingURL=#{path.basename(mapFileName)}\n*/\n"

          file.outputFileText = output
          newFiles.push file

        if ++i is options.files.length
          options.files = newFiles
          next()

  _genMapFileName: (config, file) =>
    extName = path.extname file.inputFileName
    file.inputFileName.replace(extName, ".map").replace(config.watch.sourceDir, config.watch.compiledDir)

  _genSourceName: (config, file) =>
    file.inputFileName.replace(config.watch.sourceDir, config.watch.compiledDir) + ".src"

  _cleanUpSourceMaps: (config, options, next) =>
    i = 0
    done = -> next() if ++i is 2

    options.files.forEach (file) =>
      mapFileName = @_genMapFileName(config, file)
      sourceName = @_genSourceName(config, file)
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