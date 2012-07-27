path = require 'path'
fs = require 'fs'

logger = require '../logger'

module.exports = class RequireVerify

  constructor: (@config) ->
    @rootJavaScriptDir = path.join @config.watch.compiledDir, @config.compilers.javascript.directory
    @depsRegistry = {}
    @aliasFiles = {}
    @aliasDirectories = {}

  process: (fileName, source) ->
    require = @_require(fileName)
    define = @_define(fileName)
    eval(source)

  remove: (fileName) ->
    delete @depsRegistry[fileName] if @depsRegistry[fileName]?
    @_deleteForFileName(fileName, @aliasFiles)
    @_deleteForFileName(fileName, @aliasDirectories)
    @_verifyAll()

  startupDone: (@startupComplete = true) ->
    @_verifyAll()

  _require: (fileName) ->
    (deps, callback, errback, optional) =>
      [deps, configPaths] = @_requireOverride(deps, callback, errback, optional)
      @_handleConfigPaths(fileName, configPaths) if configPaths?
      @_handleDeps(fileName, deps)

  _define: (fileName) ->
    (id, deps, funct) =>
      deps = @_defineOverride(id, deps, funct)
      @_handleDeps(fileName, deps)

  _deleteForFileName: (fileName, aliases) ->
    delete aliases[fileName] if aliases[fileName]
    for fileName, configPaths of aliases
      for alias, aliasPath of configPaths
        delete configPaths[alias] if aliasPath is fileName

  _verifyAll: ->
    for fileName, configPaths of @aliasFiles
      @_verifyConfigPaths(fileName, configPaths)
    for fileName, deps of @depsRegistry
      @_verifyDeps(fileName, deps)

  _handleConfigPaths: (fileName, configPaths) ->
    if @startupComplete
      @_verifyConfigPaths(fileName, configPaths)
    else
      @aliasFiles[fileName] = configPaths

  _verifyConfigPaths: (fileName, configPaths) ->
    @aliasFiles[fileName] = {}
    for alias, aliasPath of configPaths
      fullDepPath = @_resolvePath(fileName, aliasPath, false)
      if fullDepPath.indexOf('http') is 0
        @aliasFiles[fileName][alias] = fullDepPath
        continue

      exists = fs.existsSync fullDepPath
      if exists
        @aliasFiles[fileName][alias] = fullDepPath
      else
        pathAsDirectory = fullDepPath.replace(/.js$/, '')
        if fs.existsSync pathAsDirectory
          @aliasDirectories[fileName] ?= {}
          @aliasDirectories[fileName][alias] = pathAsDirectory
        else
          logger.error "RequireJS dependency [[ #{aliasPath} ]], inside file [[ #{fileName} ]], cannot be found."

  _handleDeps: (fileName, deps) ->
    if @startupComplete
      @_verifyDeps(fileName, deps)
    else
      @depsRegistry[fileName] = deps

  _verifyDeps: (fileName, deps) ->
    @depsRegistry[fileName] = []
    return unless deps?

    for dep in deps
      fullDepPath = @_resolvePath(fileName, dep)
      if fullDepPath.indexOf('http') is 0
        @depsRegistry[fileName].push(fullDepPath)
        continue

      exists = fs.existsSync fullDepPath
      if exists
        @depsRegistry[fileName].push(fullDepPath)
      else
        alias = @_findAlias(dep, @aliasFiles)
        if alias
          @depsRegistry[fileName].push(alias)
        else
          # test dep to see if built using directory alias
          pathWithDirReplaced = @_findPathWhenAliasDiectory(dep)
          if pathWithDirReplaced? and fs.existsSync pathWithDirReplaced
            @depsRegistry[fileName].push(pathWithDirReplaced)
          else
            logger.error "RequireJS dependency [[ #{dep} ]], inside file [[ #{fileName} ]], cannot be found."

  _findAlias: (dep, aliases) ->
    for fileName, configPaths of aliases
      return configPaths[dep] if configPaths[dep]?

  _resolvePath: (fileName, dep, includeDirectories) ->
    return dep if dep.indexOf('http') is 0 or dep.indexOf(@rootJavaScriptDir) is 0
    fullPath = if dep.charAt(0) is '.'
      path.resolve path.dirname(fileName), dep
    else
      path.join @rootJavaScriptDir, dep
    "#{fullPath}.js"

  _findPathWhenAliasDiectory: (dep) ->
    pathPieces = dep.split(path.sep)
    alias = @_findAlias(pathPieces[0], @aliasDirectories)
    if alias
      pathPieces[0] = alias
      fullPath = pathPieces.join(path.sep)
      return "#{path.normalize(fullPath)}.js"
    null

  _defineOverride: (id, deps, funct) ->
    if Array.isArray(id)
      deps = id
    else if typeof id isnt 'string'
      deps = undefined

    if deps && !Array.isArray(deps)
      deps = undefined

    deps

  _requireOverride: (deps, callback, errback, optional) ->
    if !Array.isArray(deps) and typeof deps isnt 'string'
      config = deps
      if Array.isArray(callback)
        deps = callback
      else
        deps = []
    [deps, config.paths ? null]