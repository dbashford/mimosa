path = require 'path'
fs = require 'fs'

logger = require '../logger'

module.exports = class RequireRegister

  constructor: (@config) ->
    @rootJavaScriptDir = path.join @config.watch.compiledDir, @config.compilers.javascript.directory
    @depsRegistry = {}
    @aliasFiles = {}
    @aliasDirectories = {}
    @requireFiles = []
    @tree = {}

  process: (fileName, source) ->
    require = @_require(fileName)
    define = @_define(fileName)
    try
      eval(source)
    catch e
      logger.warn "File named [#{fileName}] is not wrapped in a 'require' or 'define' function call."
      logger.warn "#{e}"

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
      @requireFiles.push fileName

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
    @_buildTree()

  _buildTree: ->
    for f in @requireFiles
      @tree[f] = []
      @_addDepsToTree(f, f, f)

    console.log "TREE"
    console.log @tree

  _addDepsToTree: (f, dep, origDep) ->
    return unless @depsRegistry[dep]?
    for aDep in @depsRegistry[dep]
      @tree[f].push(aDep) unless @tree[f].indexOf(aDep) >= 0
      @_addDepsToTree(f, aDep, dep) unless aDep is origDep # no circular

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
      @_buildTree()
    else
      @depsRegistry[fileName] = deps

  _verifyDeps: (fileName, deps) ->
    @depsRegistry[fileName] = []
    return unless deps?

    for dep in deps
      fullDepPath = @_resolvePath(fileName, dep)
      if fullDepPath.indexOf('http') is 0
        @_registerDependency(fileName, fullDepPath)
        continue

      exists = fs.existsSync fullDepPath
      if exists
        @_registerDependency(fileName, fullDepPath)
      else
        alias = @_findAlias(dep, @aliasFiles)
        if alias
          @_registerDependency(fileName, alias)
        else
          # test dep to see if built using directory alias
          pathWithDirReplaced = @_findPathWhenAliasDiectory(dep)
          if pathWithDirReplaced? and fs.existsSync pathWithDirReplaced
            @_registerDependency(fileName, pathWithDirReplaced)
          else
            logger.error "RequireJS dependency [[ #{dep} ]], inside file [[ #{fileName} ]], cannot be found."

  _registerDependency: (fileName, dependency) ->
    @depsRegistry[fileName].push(dependency)
    if @_isCircular(fileName, dependency)
      logger.warn "A circular dependency exists between [[#{fileName}]] and [[#{dependency}]]"

  _isCircular: (dep1, dep2) ->
    oneHasTwo = @depsRegistry[dep1]?.indexOf(dep2) >= 0
    twoHasOne = @depsRegistry[dep2]?.indexOf(dep1) >= 0
    oneHasTwo and twoHasOne

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