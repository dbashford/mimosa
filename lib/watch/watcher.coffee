watch = require 'chokidar'
color = require("ansi-color").set
path = require 'path'
wrench = require 'wrench'
fs = require 'fs'

class Watcher

  compilers:[]

  startWatch: (@origDir, @destDir, @ignored) ->
    files = wrench.readdirSyncRecursive(@origDir)
    files = files.filter (file) => fs.statSync(path.join(@origDir, file)).isFile()

    addTotal = 0
    watcher = watch.watch(@origDir, {persistent:true})
    watcher.on "change", (f) => @_findCompiler(f, @_updated)
    watcher.on "unlink", (f) => @_findCompiler(f, @_removed)
    watcher.on "add", (f) =>
      @_findCompiler(f, @_created)
      @_startupFinished() if ++addTotal is files.length

    console.log color("Watching #{@origDir}", "green+bold")

  _startupFinished: ->
    compiler.doneStartup() for ext, compiler of @compilers when compiler.doneStartup?

  registerCompilers: (compilers) ->
    for compiler in compilers
      compiler.setWatchedDirectories(@origDir, @destDir)
      @compilers.push(compiler)

  _findCompiler: (fileName, callback) ->
    return if @ignored.some((str) -> fileName.has(str))
    extension = path.extname(fileName).substring(1)
    return unless extension?.length > 0
    compiler = @compilers.find (comp) ->
      for ext in comp.getExtensions()
        return true if extension is ext
      return false
    if compiler?
      callback(fileName, compiler)
    else
      console.log color("No compiler has been registered: #{extension}", "yellow+bold")

  _created: (f, compiler) => @_executeCompilerMethod(f, compiler.created, "created")
  _updated: (f, compiler) => @_executeCompilerMethod(f, compiler.updated, "updated")
  _removed: (f, compiler) => @_executeCompilerMethod(f, compiler.removed, "removed")

  _executeCompilerMethod: (fileName, compilerMethod, name) =>
    if compilerMethod?
      compilerMethod(fileName)
    else
      console.log color("Compiler method #{name} does not exist, doing nothing for #{fileName}", "yellow+bold")

module.exports = (config, baseDirectory) ->

  originationDir = path.join(baseDirectory, config?.originationDir || "assets")
  destinationDir = path.join(baseDirectory, config?.destinationDir || "public")
  ignored = config?.ignored || [".sass-cache"]

  watcher = new Watcher
  watcher.startWatch(originationDir, destinationDir, ignored)
  watcher