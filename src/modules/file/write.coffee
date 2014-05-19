"use strict"


_write = (config, options, next) ->
  fileUtils = require '../../util/file'

  hasFiles = options.files?.length > 0
  return next() unless hasFiles

  i = 0
  done = ->
    next() if ++i is options.files.length

  options.files.forEach (file) ->
    return done() if (file.outputFileText isnt "" and not file.outputFileText) or not file.outputFileName

    if file.outputFileText is ""
      config.log.warn "Compile of file [[ #{file.inputFileName} ]] resulted in empty output."

    if config.log.isDebug()
      config.log.debug "Writing file [[ #{file.outputFileName} ]]"

    fileUtils.writeFile file.outputFileName, file.outputFileText, (err) ->
      if err?
        config.log.error "Failed to write new file [[ #{file.outputFileName} ]], Error: #{err}", {exitIfBuild:true}
      else
        config.log.success "Wrote file [[ #{file.outputFileName} ]]", options
      done()

exports.registration = (config, register) ->
  e = config.extensions
  register ['add','update','remove','buildExtension'], 'write', _write, [e.template..., e.css...]
  register ['add','update','buildFile'],               'write', _write, [e.javascript..., e.copy..., e.misc...]