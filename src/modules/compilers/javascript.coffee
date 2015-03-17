"use strict"

logger = require 'logmimosa'
deprecateMessageShown = false

_determineOutputFile = (config, options, next) ->
  if options.files and options.files.length
    options.destinationFile = (fileName) ->
      baseCompDir = fileName.replace(config.watch.sourceDir, config.watch.compiledDir)
      baseCompDir.substring(0, baseCompDir.lastIndexOf(".")) + ".js"

    options.files.forEach (file) ->
      file.outputFileName = options.destinationFile( file.inputFileName )

  next()

__sourceMap = (file, output, sourceMap) ->
  # already has source map?
  if output.indexOf("sourceMappingURL=") > -1
    return output

  # parse source map to object
  if typeof sourceMap is "string"
    sourceMap = JSON.parse(sourceMap)

  if !sourceMap.sources
    sourceMap.sources = []

  sourceMap.sources[0] = file.inputFileName
  sourceMap.sourcesContent = [file.inputFileText];
  #sourceMap.file = file.outputFileName;

  base64SourceMap = new Buffer(JSON.stringify(sourceMap)).toString('base64')
  datauri = 'data:application/json;base64,' + base64SourceMap
  output = "#{output}\n//# sourceMappingURL=#{datauri}\n"
  output

module.exports = class JSCompiler

  constructor: (config, @compiler) ->

  registration: (config, register) ->
    exts = @compiler.extensions(config)

    register(
      ['add','update','remove','cleanFile','buildFile'],
      'init',
      _determineOutputFile,
      exts)

    register(
      ['add','update','buildFile'],
      'compile',
      @_compile,
      exts)

  _compile: (config, options, next) =>
    return next() unless options.files?.length

    options.files.forEach (file, i) =>

      if logger.isDebug()
        logger.debug "Calling compiler function for compiler [[ " + @compiler.name + " ]]"

      file.isVendor = options.isVendor

      @compiler.compile config, file, (err, output, sourceMap, deprecated) =>

        # deprecate compilerConfig, not used
        if arguments.length is 4
          if !deprecateMessageShown
            logger.info(@compiler.name + " compiler is using deprecated compile return, please notify module author.")
            deprecateMessageShown = true
          sourceMap = deprecated

        if err
          logger.error "File [[ #{file.inputFileName} ]] failed compile. Reason: #{err}", {exitIfBuild:true}
        else
          if sourceMap
            output = __sourceMap(file, output, sourceMap)

          file.outputFileText = output

        if i is options.files.length - 1
          next()
