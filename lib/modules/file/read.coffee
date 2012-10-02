fs =   require 'fs'

logger = require '../../util/logger'

class MimosaFileReadModule

  lifecycleRegistration: (config, register) =>
    e = config.extensions
    cExts = config.copy.extensions
    register ['add','update','startupFile'],               'read', @_read, [e.javascript..., cExts...]
    register ['add','update','remove','startupExtension'], 'read', @_read, [e.css..., e.template...]

  _read: (config, options, next) ->
    return next(false) unless options.files?.length > 0

    i = 0
    done = =>
      next() if ++i is options.files.length

    options.files.forEach (file) ->
      return done() unless file.inputFileName?
      fs.readFile file.inputFileName, (err, text) =>
        return logger.error "Failed to read file: #{file.inputFileName}" if err?
        text = text.toString() if options.isJS or options.isCSS or options.isTemplate
        file.inputFileText = text
        done()

module.exports = new MimosaFileReadModule()