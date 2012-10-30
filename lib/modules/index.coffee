path = require 'path'
{exec} = require 'child_process'

_ = require 'lodash'

compilers = require './compilers'
file =      require './file'
logger =    require 'logmimosa'
pack =      require('../../package.json')

builtIns = ['mimosa-server','mimosa-lint','mimosa-require','mimosa-minify']
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
          logger.error err
        else
          logger.success "Install of '#{modName}' successful"

        logger.debug "NPM INSTALL standard out\n#{sout}"
        logger.debug "NPM INSTALL standard err\n#{serr}"
        process.chdir currentDir
        processModule()

  processModule()

module.exports =
  basic: [file, compilers]
  installedMetadata: meta
  getConfiguredModules: configured
  all:all
