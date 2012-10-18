fs =   require 'fs'

logger = require 'mimosa-logger'

class MimosaFileReadModule

  registration: (config, register) =>
    e = config.extensions
    cExts = config.copy.extensions
    register ['add','update','buildFile'],               'read', @_read, [e.javascript..., cExts...]
    register ['add','update','remove','buildExtension'], 'read', @_read, [e.css..., e.template...]

  _read: (config, options, next) ->
    return next() unless options.files?.length > 0

    i = 0
    done = =>
      next() if ++i is options.files.length

    options.files.forEach (file) ->
      return done() unless file.inputFileName?
      fs.readFile file.inputFileName, (err, text) =>
        if err?
          logger.error "Failed to read file [[ #{file.inputFileName} ]], Error: #{err}"
        else
          if options.isJavascript or options.isCSS or options.isTemplate
            text = text.toString()
          file.inputFileText = text
        done()

module.exports = new MimosaFileReadModule()