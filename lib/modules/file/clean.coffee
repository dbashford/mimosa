"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'
wrench = require 'wrench'

class MimosaCleanModule

  registration: (config, register) =>
    register ['postClean'], 'complete', @_clean

  _clean: (config, options, next) ->
    dir = config.watch.compiledDir
    directories = wrench.readdirSyncRecursive(dir).filter (f) -> fs.statSync(path.join(dir, f)).isDirectory()

    return next() if directories.length is 0

    i = 0
    done = ->
      next() if ++i is directories.length

    _.sortBy(directories, 'length').reverse().forEach (dir) ->
      dirPath = path.join(config.watch.compiledDir, dir)
      if fs.existsSync dirPath
        logger.debug "Deleting directory [[ #{dirPath} ]]"
        fs.rmdir dirPath, (err) ->
          if err?
            if err.code is "ENOTEMPTY"
              logger.info "Unable to delete directory [[ #{dirPath} ]] because directory not empty"
            else
              logger.error "Unable to delete directory, [[ #{dirPath} ]]"
              logger.error err
          else
            logger.success "Deleted empty directory [[ #{dirPath} ]]"
          done()
      else
        done()

module.exports = new MimosaCleanModule()