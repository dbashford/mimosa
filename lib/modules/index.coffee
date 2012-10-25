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

configured = (moduleNames) ->
  return configuredModules if configuredModules

  # file must be first
  configuredModules = [file, compilers, logger]
  for modName in moduleNames
    unless modName.indexOf('mimosa-') is 0
      modName = "mimosa-#{modName}"

    for installed in meta when installed.name is modName
      configuredModules.push(require modName)

  configuredModules

module.exports =
  basic: [file, compilers]
  installedMetadata: meta
  getConfiguredModules: configured
  all:all
