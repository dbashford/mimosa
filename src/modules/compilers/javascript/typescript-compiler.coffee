"use strict"

###
Meaty bits yanked from: https://github.com/eknkc/typescript-require/
With a tip of the hat to: https://github.com/joshheyse/typescript-brunch/
###

fs = require "fs"
path = require "path"

logger = require "logmimosa"

io = null
TypeScript = null
compilationSettings = null
defaultLibPath = null
mimosaConfig = {}

__setupTypeScript = ->
  io = require "./resources/io"
  TypeScript = require "./resources/typescript"

  defaultLibPath = path.join __dirname, "resources", "lib.d.ts"

  compilationSettings = new TypeScript.CompilationSettings()
  compilationSettings.codeGenTarget = TypeScript.CodeGenTarget.ES5
  compilationSettings.errorRecovery = true

  if mimosaConfig.typescript?.module?
    if mimosaConfig.typescript.module is "commonjs"
      TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Synchronous
    else if mimosaConfig.typescript.module is "amd"
      TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Asynchronous

init = (conf) ->
  mimosaConfig = conf

_compile = (file, cb) ->

  unless TypeScript
    __setupTypeScript()

  targetJsFile = file.outputFileName.replace(mimosaConfig.watch.compiledDir, mimosaConfig.watch.sourceDir)
  targetJsFile = io.resolvePath(targetJsFile)
  targetJsFile = TypeScript.switchToForwardSlashes(targetJsFile)

  outText = ""
  targetScriptAssembler =
    Write: (str) -> outText += str
    WriteLine: (str) -> outText += str + '\r\n'
    Close: ->

  depScriptWriter =
    Write: (str) ->
    WriteLine: (str) ->
    Close: ->

  errorMessage = ""
  stderr =
    Write: (str) -> errorMessage += str
    WriteLine: (str) -> errorMessage += str + '\r\n'
    Close: ->

  emitterIOHost =
    createFile: (fileName, useUTF8) ->
      if fileName is targetJsFile
        targetScriptAssembler
      else
        depScriptWriter
    directoryExists: io.directoryExists
    fileExists: io.fileExists
    resolvePath: io.resolvePath

  preEnv = new TypeScript.CompilationEnvironment(compilationSettings, io)
  resolver = new TypeScript.CodeResolver(preEnv)
  resolvedEnv = new TypeScript.CompilationEnvironment(compilationSettings, io)
  compiler = new TypeScript.TypeScriptCompiler(stderr, new TypeScript.NullLogger(), compilationSettings)
  compiler.setErrorOutput(stderr)

  if compilationSettings.errorRecovery
    compiler.parser.setErrorRecovery(stderr)

  code = new TypeScript.SourceUnit(defaultLibPath, null)
  preEnv.code.push(code)

  code = new TypeScript.SourceUnit(file.inputFileName, null)
  preEnv.code.push(code)

  resolvedPaths = {}

  resolutionDispatcher =
    postResolutionError: (errorFile, line, col, errorMessage) ->
      stderr.WriteLine("#{errorFile} (#{line}, #{col}) " + (errorMessage == "" ? "" : ": " + errorMessage))
    postResolution: (path, code) ->
      if !resolvedPaths[path]
        resolvedEnv.code.push(code)
        resolvedPaths[path] = true

  for code in preEnv.code
    path = TypeScript.switchToForwardSlashes(io.resolvePath(code.path))
    resolver.resolveCode(path, "", false, resolutionDispatcher)

  for code in resolvedEnv.code
    unless code.content is null
      compiler.addUnit(code.content, code.path, false, code.referencedFiles)

  try
    compiler.typeCheck()
    mapInputToOutput = (unitIndex, outFile) ->
      preEnv.inputOutputMap[unitIndex] = outFile
    compiler.emit emitterIOHost, mapInputToOutput
  catch err
    compiler.errorReporter.hasErrors = true

  error = if errorMessage.length > 0
    new Error(errorMessage)
  else
    null

  if /.d.ts$/.test(file.inputFileName) and outText is ""
    outText = undefined
    unless error
      logger.success "Compiled [[ " + file.inputFileName + " ]]"

  cb(error, outText)


module.exports =
  base: "typescript"
  type: "javascript"
  defaultExtensions: ["ts"]
  init: init
  compile: _compile