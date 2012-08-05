path = require 'path'
fs = require 'fs'

_ = require 'lodash'

logger = require '../logger'

module.exports = class RequireRegister

  depsRegistry: {}
  aliasFiles: {}
  aliasDirectories: {}
  requireFiles: []
  tree: {}
  mappings: {}

  setConfig: (@config) ->
    unless @rootJavaScriptDir?
      @rootJavaScriptDir = path.join @config.watch.compiledDir, @config.compilers.javascript.directory

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
    return if @startupAlreadyDone
    @startupAlreadyDone = true
    @_verifyAll()

  treeBases: ->
    Object.keys(@tree)

  treeBasesForFile: (fileName) ->
    return [fileName] if @requireFiles.indexOf(fileName) >= 0

    bases = []
    for base, deps of @tree
      bases.push(base) if deps.indexOf(fileName) >= 0
    bases

  ###
  Private
  ###

  _require: (fileName) ->
    (deps, callback, errback, optional) =>
      [deps, maps, paths] = @_requireOverride(deps, callback, errback, optional)
      @requireFiles.push fileName
      @_handleConfigPaths(fileName, maps, paths)
      @_handleDeps(fileName, deps)

  _define: (fileName) ->
    (id, deps, funct) =>
      deps = @_defineOverride(id, deps, funct)
      @_handleDeps(fileName, deps)

  _deleteForFileName: (fileName, aliases) ->
    delete aliases[fileName] if aliases[fileName]
    for fileName, paths of aliases
      for alias, aliasPath of paths
        delete paths[alias] if aliasPath is fileName

  _verifyAll: ->
    @_verifyConfigForFile(file)  for file in @requireFiles
    @_verifyFileDeps(file, deps) for file, deps  of @depsRegistry
    @_buildTree()

  _buildTree: ->
    for f in @requireFiles
      @tree[f] = []
      @_addDepsToTree(f, f, f)

  _addDepsToTree: (f, dep, origDep) ->
    return unless @depsRegistry[dep]?
    for aDep in @depsRegistry[dep]
      @tree[f].push(aDep) unless @tree[f].indexOf(aDep) >= 0
      @_addDepsToTree(f, aDep, dep) unless aDep is origDep # no circular

  _handleConfigPaths: (fileName, maps, paths) ->
    if @startupComplete
      @_verifyConfigForFile(fileName, maps, paths)
      @_verifyFileDeps(file, deps) for file, deps of @depsRegistry
    else
      @aliasFiles[fileName] = paths
      @mappings[fileName] = maps

  _handleDeps: (fileName, deps) ->
    if @startupComplete
      @_verifyFileDeps(fileName, deps)
      @_buildTree()
    else
      @depsRegistry[fileName] = deps

  _verifyConfigForFile: (fileName, maps, paths) ->
    @aliasFiles[fileName] = {}
    @_verifyConfigMappings(fileName, maps ? @mappings[fileName])
    @_verifyConfigPaths(fileName, paths ? @aliasFiles[fileName])

  _verifyConfigMappings: (fileName, maps) ->
    # rewrite module paths to full paths
    for module, mappings of maps
      if module isnt '*'
        fullDepPath = @_resolvePath(fileName, module, false)
        exists = fs.existsSync fullDepPath
        if exists
          delete maps[module]
          maps[fullDepPath] = mappings
        else
          logger.error "RequireJS mapping inside file [[ #{fileName} ]], refers to module that cannot be found [[ #{module} ]]."
          continue

    for module, mappings of maps
      for alias, aliasPath of mappings
        fullDepPath = @_resolvePath(fileName, aliasPath, false)
        if fullDepPath.indexOf('http') is 0
          @aliasFiles[fileName][alias] = "MAPPED!#{alias}"
          continue

        exists = fs.existsSync fullDepPath
        if exists
          @aliasFiles[fileName][alias] = "MAPPED!#{alias}"
          maps[module][alias] = fullDepPath
        else
          # ??? Can paths in mappings utilize paths to paths set up in config.paths?
          # i.e. could this work => '*': {'v/jquery':'jquery1.4'} if 'v' didn't exist and
          # was set up like so => 'paths':{"v":"vendor"}
          # this assumes no
          logger.error "RequireJS mapping inside file [[ #{fileName} ]], for module [[ #{module} ]] has path that cannot be found [[#{aliasPath}]]."

  _verifyConfigPaths: (fileName, paths) ->
    for alias, aliasPath of paths
      continue if aliasPath.indexOf("MAPPED") is 0
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

  _verifyFileDeps: (fileName, deps) ->
    @depsRegistry[fileName] = []
    return unless deps?

    for dep in deps
      # require is valid dependency all by itself
      continue if dep is 'require'

      # as are web resources, CDN, etc
      if dep.indexOf('http') is 0
        @_registerDependency(fileName, dep)
        continue

      # resolve path, if mapped, find already calculated map path
      fullDepPath = if dep.indexOf('MAPPED') is 0
        @_findMappedDepedency(fileName, dep)
      else
        @_resolvePath(fileName, dep)

      exists = fs.existsSync fullDepPath
      if exists
        # file exists, register it
        @_registerDependency(fileName, fullDepPath)
      else
        alias = @_findAlias(dep, @aliasFiles)
        if alias
          # file does not exist, but is aliased, register it
          @_registerDependency(fileName, alias)
        else
          pathWithDirReplaced = @_findPathWhenAliasDiectory(dep)
          if pathWithDirReplaced? and fs.existsSync pathWithDirReplaced
            # file does not exist, but can be found by following directory alias
            @_registerDependency(fileName, pathWithDirReplaced)
          else
            # much sadness, cannot find the dependency
            logger.error "RequireJS dependency [[ #{dep} ]], inside file [[ #{fileName} ]], cannot be found."

  _findMappedDepedency: (fileName, dep) ->
    depName = dep.split('!')[1]

    for mainFile, mappings of @mappings
      return mappings[fileName][depName] if mappings[fileName]?[depName]?

    for mainFile, mappings of @mappings
      return mappings['*'][depName] if mappings['*']?[depName]?

    logger.error "Mimosa has a bug! Ack! Cannot find mapping and it really should have."

  _registerDependency: (fileName, dependency) ->
    @depsRegistry[fileName].push(dependency)
    if @_isCircular(fileName, dependency)
      logger.warn "A circular dependency exists between [[#{fileName}]] and [[#{dependency}]]"

  _isCircular: (dep1, dep2) ->
    oneHasTwo = @depsRegistry[dep1]?.indexOf(dep2) >= 0
    twoHasOne = @depsRegistry[dep2]?.indexOf(dep1) >= 0
    oneHasTwo and twoHasOne

  _findAlias: (dep, aliases) ->
    for fileName, paths of aliases
      return paths[dep] if paths[dep]?

  _resolvePath: (fileName, dep, includeDirectories) ->
    return dep if dep.indexOf(@rootJavaScriptDir) is 0
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
    [deps, config.map ? null, config.paths ? null]

module.exports = new RequireRegister()