"use strict"

fs = require 'fs'
path = require 'path'

_ = require 'lodash'
logger = require 'logmimosa'
wrench = require 'wrench'

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
    files = wrench.readdirSyncRecursive(jsDir)
      .filter (f) ->
        /-built.js$/.test(f)
      .map (f) ->
        f = path.join jsDir, f
        fs.unlinkSync f
        logger.success "Deleted file [[ #{f} ]]"

    cb()

  __cleanUp: (config, cb) ->
    dir = config.watch.compiledDir
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