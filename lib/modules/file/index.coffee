fs =   require 'fs'

logger =    require '../../util/logger'
fileUtils = require '../../util/file'

init = require './init'
beforeRead = require './beforeRead'
read = require './read'
write = require './write'
modules = [init, beforeRead, read, write]

class MimosaFileModule

  lifecycleRegistration: (config, register) ->
    modules.forEach (module) ->
      module.lifecycleRegistration(config, register)

  _delete: (config, options, next) =>
    fileName = options.destinationFile
    logger.debug "Removing file [[ #{fileName} ]]"
    fs.unlink fileName, (err) =>
      return logger.error "Failed to delete file: #{fileName}"
      # @success "Deleted compiled file [[ #{fileName} ]]"
      next()

module.exports = new MimosaFileModule()