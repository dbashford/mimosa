"use strict"

fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

_ =      require 'lodash'
logger = require 'logmimosa'
skels =  require 'skelmimosa'
newmod = require 'newmimosa'

compilers =     require './compilers'
file =          require './file'
mimosaPackage = require('../../package.json')

builtIns = [
  'mimosa-copy'
  'mimosa-server'
  'mimosa-jshint'
  'mimosa-csslint'
  'mimosa-require'
  'mimosa-minify-js'
  'mimosa-minify-css'
  'mimosa-live-reload'
  'mimosa-bower'
]
configuredModules = null

isMimosaModuleName = (str) -> str.indexOf('mimosa-') > -1

projectNodeModules = path.resolve process.cwd(), 'node_modules'
locallyInstalled = if fs.existsSync projectNodeModules
    _(fs.readdirSync projectNodeModules)
      .select(isMimosaModuleName)
      .select (dep) ->
        try
          require path.join projectNodeModules, dep
          true
        catch err
          logger.error "Error pulling in local Mimosa module: #{err}"
          process.exit 1
      .map (dep) ->
        local: true
        name: dep
        nodeModulesDir: projectNodeModules
      .value()
  else
    []

locallyInstalledNames = _.pluck locallyInstalled, 'name'
standardlyInstalled = _(mimosaPackage.dependencies)
  .keys()
  .select (dir) ->
    isMimosaModuleName(dir) and dir not in locallyInstalledNames
  .map (dep) ->
    name: dep
    nodeModulesDir: '../../node_modules'
  .value()

independentlyInstalled = do ->
  topLevelNodeModulesDir = path.resolve __dirname, '../../..'
  standardlyResolvedModules = _.pluck standardlyInstalled, 'name'
  _(fs.readdirSync topLevelNodeModulesDir)
    .select (dir) ->
      isMimosaModuleName(dir) and dir not in standardlyResolvedModules and dir not in locallyInstalledNames
    .map (dir) ->
      name: dir
      nodeModulesDir: topLevelNodeModulesDir
    .value()

allInstalled = standardlyInstalled.concat(independentlyInstalled).concat(locallyInstalled)
meta = _.map allInstalled, (modInfo) ->
  requireString = "#{modInfo.nodeModulesDir}/#{modInfo.name}/package.json"
  try
    modPack = require requireString

    mod:     if modInfo.local then require "#{modInfo.nodeModulesDir}/#{modInfo.name}/" else require modInfo.name
    name:    modInfo.name
    version: modPack.version
    site:    modPack.homepage
    desc:    modPack.description
    default: if builtIns.indexOf(modInfo.name) > -1 then "yes" else "no"
    dependencies: modPack.dependencies
  catch err
    resolvedPath = path.resolve requireString
    logger.error "Unable to read file at [[ #{resolvedPath} ]], possibly a permission issue? \nsystem error : #{err}"
    process.exit 1

metaNames = _.pluck meta, 'name'
configModuleString = if _.difference(metaNames, builtIns).length > 0
  names = metaNames.map (name) -> name.replace 'mimosa-', ''
  JSON.stringify names

configured = (moduleNames, callback) ->
  return configuredModules if configuredModules

  # file must be first
  configuredModules = [file, compilers, logger]
  index = 0

  processModule = ->
    if index is moduleNames.length
      return callback(configuredModules)

    modName = moduleNames[index++]
    unless modName.indexOf('mimosa-') is 0
      modName = "mimosa-#{modName}"

    fullModName = modName

    if modName.indexOf('@') > 7
      modParts = modName.split('@')
      modName = modParts[0]
      modVersion = modParts[1]

    found = false
    for installed in meta when installed.name is modName
      unless modVersion? and modVersion isnt installed.version
        found = true
        installed.mod.__mimosaModuleName = modName
        configuredModules.push installed.mod
        break

    if found
      processModule()
    else
      logger.info "Module [[ #{fullModName} ]] cannot be found, attempting to install it from NPM into your project."

      nodeModules = path.join process.cwd(), "node_modules"
      unless fs.existsSync nodeModules
        logger.info "node_modules directory does not exist, creating one..."
        fs.mkdirSync nodeModules

      installString = "npm install #{fullModName}"
      exec installString, (err, sout, serr) =>
        if err
          console.log ""
          logger.error "Unable to install [[ #{fullModName} ]]\n"
          logger.info "Does the module exist in npm (https://npmjs.org/package/#{fullModName})?\n"
          logger.error err

          process.exit 1
        else
          console.log sout
          logger.success "[[ #{fullModName} ]] successfully installed into your project."

          modPath = path.join nodeModules, modName
          Object.keys(require.cache).forEach (key) ->
            if key.indexOf(modPath) is 0
              delete require.cache[key]

          try
            requiredModule = require modPath
            requiredModule.__mimosaModuleName = modName
            configuredModules.push(requiredModule)
          catch err
            logger.warn "There was an error attempting to include the newly installed module in the currently running Mimosa process," +
              " but the install was successful. Mimosa is exiting. When it is restarted, Mimosa will use the newly installed module."
            logger.debug err

            process.exit 0

        #logger.debug "NPM INSTALL standard out\n#{sout}"
        #logger.debug "NPM INSTALL standard err\n#{serr}"

        processModule()

  processModule()

all = [compilers, logger, file, skels, newmod].concat _.pluck(meta, 'mod')

modulesWithCommands = ->
  mods = []
  for mod in all
    if mod.registerCommand?
      mods.push mod
  mods

module.exports =
  installedMetadata:    meta
  getConfiguredModules: configured
  all:                  all
  configModuleString:   configModuleString
  modulesWithCommands:  modulesWithCommands
