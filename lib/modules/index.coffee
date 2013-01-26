"use strict"

fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'

_ = require 'lodash'

compilers = require './compilers'
file =      require './file'
logger =    require 'logmimosa'
pack =      require('../../package.json')

builtIns = ['mimosa-server','mimosa-lint','mimosa-require','mimosa-minify','mimosa-live-reload']
configuredModules = null

isMimosaModuleName = (str) -> str.indexOf('mimosa-') > -1

standardlyInstalled = _(pack.dependencies)
  .keys()
  .select(isMimosaModuleName)
  .map (dep) ->
    name: dep
    nodeModulesDir: '../../node_modules'
  .value()

independentlyInstalled = do ->
  topLevelNodeModulesDir = path.resolve __dirname, '../../..'
  standardlyResolvedModules = _.pluck standardlyInstalled, 'name'
  _(fs.readdirSync topLevelNodeModulesDir)
    .select (dir) ->
      isMimosaModuleName(dir) and dir not in standardlyResolvedModules
    .map (dir) ->
      name: dir
      nodeModulesDir: topLevelNodeModulesDir
    .value()

meta = _.map standardlyInstalled.concat(independentlyInstalled), (modInfo) ->
  requireString = "#{modInfo.nodeModulesDir}/#{modInfo.name}/package.json"
  try
    modPack = require requireString
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

all = [compilers, logger, file].concat _.map(_.pluck(meta, 'name'), require)

allDefaults = true
if builtIns.length isnt meta.length
  allDefaults = false
else
  for builtIn in builtIns
    found = false
    for aMeta in meta
      if aMeta.name is builtIn
        found = true
        break
    if not found
      allDefaults = false
      break

configModuleString = unless allDefaults
  names = _.pluck(meta, 'name')
  names = names.map (name) -> name.replace 'mimosa-', ''
  JSON.stringify(names)

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
        configuredModules.push(require modName)
        break

    if found
      processModule()
    else
      logger.info "Module [[ #{fullModName} ]] not installed inside your Mimosa, attempting to install it from NPM."

      currentDir = process.cwd()
      mimosaPath = path.join __dirname, '..', '..'
      process.chdir mimosaPath

      installString = "npm install #{fullModName} --save"
      exec installString, (err, sout, serr) =>
        if err
          console.log ""
          logger.error "Unable to install [[ #{fullModName} ]]\n"
          logger.info "Does the module exist in npm (https://npmjs.org/package/#{fullModName})?\n"
          logger.info "Or, if your Mimosa is installed globally, might there be permissions issues with installing global npm packages? If you do not have the rights to do an 'npm install -g', modules will not install.\n"
          logger.error err

          process.exit 1
        else
          logger.success "Install of '#{fullModName}' successful"

          modPath = path.join mimosaPath, "node_modules", modName
          Object.keys(require.cache).forEach (key) ->
            if key.indexOf(modPath) is 0
              delete require.cache[key]

          try
            configuredModules.push(require modName)
          catch err
            logger.warn "There was an error attempting to include the newly installed module in the currently running Mimosa process," +
              "but the install was successful. Mimosa is exiting. When it is restarted, Mimosa will use the newly installed module."
            logger.debug err

            process.exit 0

        logger.debug "NPM INSTALL standard out\n#{sout}"
        logger.debug "NPM INSTALL standard err\n#{serr}"
        process.chdir currentDir
        processModule()

  processModule()

modulesWithCommands = ->
  mods = []
  for mod in all
    if mod.registerCommand?
      mods.push mod

  #logger.info "There are #{mods.length} command mods"

  mods

module.exports =
  basic:                [file, compilers]
  installedMetadata:    meta
  getConfiguredModules: configured
  all:                  all
  configModuleString:   configModuleString
  modulesWithCommands:  modulesWithCommands