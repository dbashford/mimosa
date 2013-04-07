"use strict"

###
Meaty bits yanked from: https://github.com/eknkc/typescript-require/
With a tip of the hat to: https://github.com/joshheyse/typescript-brunch/
###

fs = require "fs"
path = require "path"

logger = require "logmimosa"

io = require "./assets/io"

TypeScript = require "./assets/typescript"
JSCompiler = require "./javascript"

module.exports = class TypeScriptCompiler extends JSCompiler

  @prettyName        = "TypeScript - http://www.typescriptlang.org"
  @defaultExtensions = ["ts"]

  constructor: (config, @extensions) ->
    super()

    @defaultLibPath = path.join __dirname, "assets", "lib.d.ts"

    @compilationSettings = new TypeScript.CompilationSettings()
    @compilationSettings.codeGenTarget = TypeScript.CodeGenTarget.ES5
    @compilationSettings.errorRecovery = true    

    if config.typescript?.module?
      if config.typescript.module is "commonjs"
        TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Synchronous
      else if config.typescript.module is "amd"
        TypeScript.moduleGenTarget = TypeScript.ModuleGenTarget.Asynchronous

  compile: (file, cb) ->

    targetJsFile = file.inputFileName.substr(0, file.inputFileName.length - 3) + '.js';
    targetJsFile = io.resolvePath(targetJsFile);
    targetJsFile = TypeScript.switchToForwardSlashes(targetJsFile);

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
              return targetScriptAssembler
            else
              return depScriptWriter
        directoryExists: io.directoryExists
        fileExists: io.fileExists
        resolvePath: io.resolvePath

    preEnv = new TypeScript.CompilationEnvironment(@compilationSettings, io)
    resolver = new TypeScript.CodeResolver(preEnv)
    resolvedEnv = new TypeScript.CompilationEnvironment(@compilationSettings, io)
    compiler = new TypeScript.TypeScriptCompiler(stderr, new TypeScript.NullLogger(), @compilationSettings)
    compiler.setErrorOutput(stderr)
    
    if @compilationSettings.errorRecovery
        compiler.parser.setErrorRecovery(stderr)

    code = new TypeScript.SourceUnit(@defaultLibPath, null)
    preEnv.code.push(code)

    code = new TypeScript.SourceUnit(file.inputFileName, null)
    preEnv.code.push(code)

    resolvedPaths = {}

    resolutionDispatcher =
        postResolutionError: (errorFile, line, col, errorMessage) ->
            stderr.WriteLine(errorFile + "(" + line + "," + col + ") " + (errorMessage == "" ? "" : ": " + errorMessage))
        postResolution: (path, code) ->
            if (!resolvedPaths[path])
                resolvedEnv.code.push(code)
                resolvedPaths[path] = true    

    for code in preEnv.code
        path = TypeScript.switchToForwardSlashes(io.resolvePath(code.path))
        resolver.resolveCode(path, "", false, resolutionDispatcher)
    
    for code in resolvedEnv.code
        if (code.content != null)
            compiler.addUnit(code.content, code.path, false, code.referencedFiles)

    try
      compiler.typeCheck()
      mapInputToOutput = (unitIndex, outFile) ->
          preEnv.inputOutputMap[unitIndex] = outFile
      compiler.emit emitterIOHost, mapInputToOutput
    catch err
        compiler.errorReporter.hasErrors = true;
    
    error = if errorMessage.length > 0 
      new Error(errorMessage)
    else
      null

    if /.d.ts$/.test(file.inputFileName) and outText is ""
        outText = undefined
        unless error
          logger.success "Compiled [[ " + file.inputFileName + " ]]"       
    
    cb(error, outText)