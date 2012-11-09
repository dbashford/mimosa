"use strict"

path = require 'path'
{exec} = require 'child_process'

_ = require 'lodash'

compilers = require './compilers'
file =      require './file'
logger =    require 'logmimosa'
pack =      require('../../package.json')

builtIns = ['mimosa-server','mimosa-lint','mimosa-require','mimosa-minify','mimosa-live-reload']
configuredModules = null
meta = []
all = [compilers, logger, file]

for dep, version of pack.dependencies when dep.indexOf('mimosa-') > -1
  modPack = require("../../node_modules/#{dep}/package.json")
  all.push(require dep)
  meta.push
    name:    dep
    version: modPack.version
    site:    modPack.homepage
    desc:    modPack.description
    default: if builtIns.indexOf(dep) > -1 then "yes" else "no"
    dependencies: modPack.dependencies

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

    modName = moduleNames[index]
    index++
    unless modName.indexOf('mimosa-') is 0
      modName = "mimosa-#{modName}"

    found = false
    for installed in meta
      if installed.name is modName
        found = true
        configuredModules.push(require modName)
        break

    if found
      processModule()
    else
      logger.info "Module [[ #{modName} ]] not installed inside your Mimosa, attempting to install it from NPM."

      currentDir = process.cwd()
      mimosaPath = path.join __dirname, '..', '..'
      process.chdir mimosaPath

      installString = "npm install #{modName} --save"
      exec installString, (err, sout, serr) =>
        if err
          logger.error "Unable to install [[ #{modName} ]], but allowing Mimosa to continue.  Install error follows."
          logger.warn err
        else
          logger.success "Install of '#{modName}' successful"
          configuredModules.push(require modName)

        logger.debug "NPM INSTALL standard out\n#{sout}"
        logger.debug "NPM INSTALL standard err\n#{serr}"
        process.chdir currentDir
        processModule()

  processModule()

module.exports =
  basic:                [file, compilers]
  installedMetadata:    meta
  getConfiguredModules: configured
  all:                  all
  configModuleString:   configModuleString