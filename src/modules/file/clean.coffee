"use strict"

_clean = (config, options, next) ->
  fs = require 'fs'
  path = require 'path'
  _ = require 'lodash'
  wrench = require 'wrench'

  dir = config.watch.compiledDir
  directories = wrench.readdirSyncRecursive(dir).filter (f) -> fs.statSync(path.join(dir, f)).isDirectory()

  return next() if directories.length is 0

  i = 0
  done = ->
    next() if ++i is directories.length

  _.sortBy(directories, 'length').reverse().forEach (dir) ->
    dirPath = path.join(config.watch.compiledDir, dir)
    if fs.existsSync dirPath
      if config.log.isDebug()
        config.log.debug "Deleting directory [[ #{dirPath} ]]"
      try
        fs.rmdirSync dirPath
        config.log.success "Deleted empty directory [[ #{dirPath} ]]"
      catch err
        if err.code is 'ENOTEMPTY'
          config.log.info "Unable to delete directory [[ #{dirPath} ]] because directory not empty"
        else
          config.log.error "Unable to delete directory, [[ #{dirPath} ]]"
          config.log.error err
    done()

exports.registration = (config, register) ->
  register ['postClean'], 'complete', _clean