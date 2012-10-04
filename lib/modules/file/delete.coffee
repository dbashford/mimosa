fs = require 'fs'

logger =    require '../../util/logger'

class MimosaFileDeleteModule

  lifecycleRegistration: (config, register) =>
    e = config.extensions
    cExts = config.copy.extensions
    register ['remove'], 'delete', @_delete, [e.javascript..., e.css..., cExts...]

  _delete: (config, options, next) =>
    fileName = options.destinationFile(options.inputFile)
    fs.exists fileName, (exists) ->
      return next() unless exists
      logger.debug "Removing file [[ #{fileName} ]]"
      fs.unlink fileName, (err) =>
        if err
          logger.error "Failed to delete file [[ #{fileName} ]]"
        else
          logger.success "Deleted compiled file [[ #{fileName} ]]", options
        next()

module.exports = new MimosaFileDeleteModule()