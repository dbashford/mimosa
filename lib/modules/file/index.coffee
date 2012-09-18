path = require 'path'

logger = require '../../util/logger'

class MimosaCompiledPath

  lifecycleRegistration: (config) ->
    lifecycle = []

    lifecycle.push
      types:['add','update','remove', 'startup']
      step:'beforeRead'
      callback: @_beforeRead
      extensions:['*']

    lifecycle

  _beforeRead: (config, options, next) ->
    logger.debug "Executing modules.file.beforeRead"

    # shortcut variables
    inputFile = options.inputFile
    watchDir = config.watch.sourceDir
    compiledDir = config.watch.compiledDir
    compiledJSDir = config.watch.compiledJavascriptDir
    exts = config.extensions

    ext = path.extname(inputFile).substring(1)

    destinationFile = if exts.template.indexOf(ext) > -1
      outputFileName = config.template.outputFileName
      if outputFileName[ext]
        path.join(compiledJSDir, outputFileName[ext] + ".js")
      else
        path.join(compiledJSDir, outputFileName + ".js")
    else
      baseCompDir = inputFile.replace(watchDir, compiledDir)
      if exts.copy.indexOf(ext) > -1
        baseCompDir
      else if exts.javascript.indexOf(ext) > -1
        baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js"
      else if exts.css.indexOf(ext) > -1
        baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".css"

    if destinationFile?
      logger.debug "Destination for file [[ #{inputFile} ]] is [[ #{destinationFile} ]]"
      options.destinationFile = destinationFile
      next()
    else
      # no error, just unrecognized extension, warn and do not continue
      logger.warn "No compiler has been registered: #{ext}, #{inputFile}"

module.exports = new MimosaCompiledPath()