"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'
wrench = require 'wrench'

fileUtils = require '../../util/file'

class MimosaCleanModule

  registration: (config, register) =>
    register ['postClean'], 'complete', @_clean

  _clean: (config, options, next) =>
    i = 0
    done = ->
      next() if ++i is 2

    @__cleanMisc config, done
    @__cleanUp config, done

  __cleanMisc: (config, cb) ->
    jsDir = path.join config.watch.compiledDir, config.watch.javascriptDir
    files = fileUtils.glob "#{jsDir}/**/*-built.js"

    i = 0
    done = ->
      cb() if ++i is files.length + 1

    for file in files
      logger.debug("Deleting '-built' file, [[ #{file} ]]")
      fs.unlink file, (err) ->
        logger.success "Deleted file [[ #{file} ]]"
        done()

    compiledJadeFile = path.join config.watch.compiledDir, 'index.html'
    fs.exists compiledJadeFile, (exists) ->
      if exists
        logger.debug("Deleting compiledJadeFile [[ #{compiledJadeFile} ]]")
        fs.unlink compiledJadeFile, (err) ->
          logger.success "Deleted file [[ #{compiledJadeFile} ]]"
          done()
      else
        done()

  __cleanUp: (config, cb) ->
    dir = config.watch.sourceDir
    directories = wrench.readdirSyncRecursive(dir).filter (f) -> fs.statSync(path.join(dir, f)).isDirectory()

    return cb() if directories.length is 0

    i = 0
    done = ->
      cb() if ++i is directories.length

    _.sortBy(directories, 'length').reverse().forEach (dir) ->
      dirPath = path.join(config.watch.compiledDir, dir)
      if fs.existsSync dirPath
        logger.debug "Deleting directory [[ #{dirPath} ]]"
        fs.rmdir dirPath, (err) ->
          if err?.code is not "ENOTEMPTY"
            logger.error "Unable to delete directory, #{dirPath}"
            logger.error err
          else
            logger.success "Deleted empty directory [[ #{dirPath} ]]"
          done()
      else
        done()

module.exports = new MimosaCleanModule()