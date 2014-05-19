"use strict"

_read = (config, options, next) ->
  fs =   require 'fs'

  hasFiles = options.files?.length > 0
  return next() unless hasFiles

  i = 0
  done = ->
    next() if ++i is options.files.length

  options.files.forEach (file) ->
    return done() unless file.inputFileName?
    fs.readFile file.inputFileName, (err, text) ->
      if err?
        config.log.error "Failed to read file [[ #{file.inputFileName} ]], #{err}", {exitIfBuild:true}
      else
        if options.isJavascript or options.isCSS or options.isTemplate
          text = text.toString()
        file.inputFileText = text
      done()

exports.registration = (config, register) ->
  e = config.extensions
  register ['add','update','buildFile'],               'read', _read, [e.javascript..., e.copy..., e.misc...]
  register ['add','update','remove','buildExtension'], 'read', _read, [e.css..., e.template...]