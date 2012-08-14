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
  shims: {}

  setConfig: (@config) ->
    @verify = @config.require.verify.enabled
    unless @rootJavaScriptDir?
      @rootJavaScriptDir = path.join @config.watch.compiledDir, @config.compilers.javascript.directory

  process: (fileName, source) ->
    require = @_require(fileName)
    define = @_define(fileName)
    requirejs = require
    requirejs.config = require
    @_requirejs(requirejs)
    try
      eval(source)
    catch e
      @_logger "File named [#{fileName}] is not wrapped in a 'require' or 'define' function call.", "warm"
      @_logger "#{e}", 'warn'

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

  _logger: (message, method = 'error') ->
    logger[method](message) if @verify

  _require: (fileName) ->
    (deps, callback, errback, optional) =>
      [deps, config] = @_requireOverride(deps, callback, errback, optional)
      if config
        @requireFiles.push fileName
        @_handleConfigPaths(fileName, config.map ? null, config.paths ? null)
        @_handleShims(fileName, config.shims ? null)
      @_handleDeps(fileName, deps)


  _define: (fileName) ->
    (id, deps, funct) =>
      deps = @_defineOverride(id, deps, funct)
      @_handleDeps(fileName, deps)

  # may not be necessary, but for future reference
  _requirejs: (r) ->
    r.version = ''
    r.onError = ->
    r.jsExtRegExp = /^\/|:|\?|\.js$/
    r.isBrowser = true
    r.load = ->
    r.exec = ->
    r.toUrl = -> ""
    r.undef = ->
    r.defined = ->
    r.specified = ->

  _deleteForFileName: (fileName, aliases) ->
    delete aliases[fileName] if aliases[fileName]
    for fileName, paths of aliases
      for alias, aliasPath of paths
        delete paths[alias] if aliasPath is fileName

  _verifyAll: ->
    @_verifyConfigForFile(file)  for file in @requireFiles
    @_verifyFileDeps(file, deps) for file, deps of @depsRegistry
    @_verifyShims(file, shims) for file, shims of @shims
    @_buildTree()

  _handleShims: (fileName, shims) ->
    if @startupComplete
      @_verifyShims(fileName, shims)
    else
      @shims[fileName] = shims

  _verifyShims: (fileName, shims) ->
    return unless shims?

    for name, config of shims
      unless fs.existsSync @_resolvePath(fileName, name, false)
        @_logger "RequireJS shim [[ #{name} ]] inside file [[ #{fileName} ]] cannot be found."

      deps = if Array.isArray(config) then config else config.deps
      if deps?
        for dep in deps
          unless fs.existsSync @_resolvePath(fileName, dep, false)
            @_logger "RequireJS shim [[ #{name} ]] inside file [[ #{fileName} ]] refers to a dependency that cannot be found [[ #{dep} ]]."

  _buildTree: ->
    for f in @requireFiles
      @tree[f] = []
      @_addDepsToTree(f, f, f)

  _addDepsToTree: (f, dep, origDep) ->
    return unless @depsRegistry[dep]?
    for aDep in @depsRegistry[dep]
      exists = fs.existsSync aDep

      unless exists
        aDep = @_findAlias(aDep, @aliasFiles)
        return unless aDep?  # is bad file path
        if aDep.indexOf('MAPPED!') >= 0
          aDep = @_findMappedDepedency(dep, aDep)

      @tree[f].push(aDep) unless @tree[f].indexOf(aDep) >= 0
      @_addDepsToTree(f, aDep, dep) unless aDep is origDep # no circular

  _handleConfigPaths: (fileName, maps, paths) ->
    if @startupComplete
      @_verifyConfigForFile(fileName, maps, paths)
      # remove the dependencies for the config file as
      # they'll get checked after the config paths are checked in
      @depsRegistry[fileName] = []
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
    # if nothing passed in, then is verify all
    maps = maps ? @mappings[fileName]
    paths = if paths
      paths
    else
      paths = {}
      paths = _.extend(paths, @aliasFiles[fileName])       if @aliasFiles[fileName]?
      paths = _.extend(paths, @aliasDirectories[fileName]) if @aliasDirectories[fileName]?
      paths

    @aliasFiles[fileName] = {}
    @aliasDirectories[fileName] = {}
    @_verifyConfigMappings(fileName, maps)
    @_verifyConfigPath(fileName, alias, aliasPath) for alias, aliasPath of paths

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
          @_logger "RequireJS mapping inside file [[ #{fileName} ]], refers to module that cannot be found [[ #{module} ]]."
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
          @_logger "RequireJS mapping inside file [[ #{fileName} ]], for module [[ #{module} ]] has path that cannot be found [[#{aliasPath}]]."

  _verifyConfigPath: (fileName, alias, aliasPath) ->
    if Array.isArray(aliasPath)
      for aPath in aliasPath
        @_verifyConfigPath(fileName, alias, aPath)
      return

    return if aliasPath.indexOf("MAPPED") is 0

    # as are web resources, CDN, etc
    if aliasPath.indexOf('http') is 0
      return @aliasFiles[fileName][alias] = aliasPath

    fullDepPath = @_resolvePath(fileName, aliasPath, false)

    exists = fs.existsSync fullDepPath
    if exists
      if fs.statSync(fullDepPath).isDirectory()
        @aliasDirectories[fileName][alias] = fullDepPath
      else
        @aliasFiles[fileName][alias] = fullDepPath
    else
      pathAsDirectory = fullDepPath.replace(/.js$/, '')
      if fs.existsSync pathAsDirectory
        @aliasDirectories[fileName] ?= {}
        @aliasDirectories[fileName][alias] = pathAsDirectory
      else
        @_logger "RequireJS dependency [[ #{aliasPath} ]] for path alias [[ #{alias} ]], inside file [[ #{fileName} ]], cannot be found."

  _verifyFileDeps: (fileName, deps) ->
    @depsRegistry[fileName] = []
    return unless deps?
    @_verifyDep(fileName, dep) for dep in deps

  _verifyDep: (fileName, dep) ->
    # require, module = valid dependencies passed by require
    return if dep is 'require' or dep is 'module'

    # as are web resources, CDN, etc
    if dep.indexOf('http') is 0
      return @_registerDependency(fileName, dep)

    # handle plugins
    if dep.indexOf('!') >= 0
      [plugin, dep] = dep.split('!')
      @_verifyDep(fileName, plugin)

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
        # file does not exist, but is aliased, register the alias
        @_registerDependency(fileName, dep)
      else
        pathWithDirReplaced = @_findPathWhenAliasDiectory(dep)
        if pathWithDirReplaced? and fs.existsSync pathWithDirReplaced
          # file does not exist, but can be found by following directory alias
          @_registerDependency(fileName, pathWithDirReplaced)
        else
          @_registerDependency(fileName, dep)
          # much sadness, cannot find the dependency
          @_logger "RequireJS dependency [[ #{dep} ]], inside file [[ #{fileName} ]], cannot be found."

  _findMappedDepedency: (fileName, dep) ->
    depName = dep.split('!')[1]

    for mainFile, mappings of @mappings
      return mappings[fileName][depName] if mappings[fileName]?[depName]?

    for mainFile, mappings of @mappings
      return mappings['*'][depName] if mappings['*']?[depName]?

    @_logger "Mimosa has a bug! Ack! Cannot find mapping and it really should have."

  _registerDependency: (fileName, dependency) ->
    @depsRegistry[fileName].push(dependency)
    if @_isCircular(fileName, dependency)
      @_logger "A circular dependency exists between [[#{fileName}]] and [[#{dependency}]]", 'warn'

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

    [deps, config]

module.exports = new RequireRegister()