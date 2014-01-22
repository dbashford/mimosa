"use strict"

fs = require 'fs'

logger = require 'logmimosa'

class MimosaFileDeleteModule

  registration: (config, register) =>
    e = config.extensions
    register ['remove','cleanFile'], 'delete', @_delete, [e.javascript..., e.css..., e.copy...]

  _delete: (config, options, next) =>
    fileName = options.destinationFile(options.inputFile)
    fs.exists fileName, (exists) ->
      unless exists
        logger.debug "File does not exist? [[ #{fileName} ]]"
        return next()
      logger.debug "Removing file [[ #{fileName} ]]"
      fs.unlink fileName, (err) ->
        if err
          logger.error "Failed to delete file [[ #{fileName} ]]"
        else
          logger.success "Deleted file [[ #{fileName} ]]", options
        next()

module.exports = new MimosaFileDeleteModule()