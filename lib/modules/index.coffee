_ = require 'lodash'

compilers = require './compilers'
file =      require './file'
logger =    require 'logmimosa'
all = [file, compilers, logger]

pack =      require('../../package.json')

builtIns = ['mimosa-server','mimosa-lint','mimosa-require','mimosa-minify']

meta = []

discoverModules = ->
  for dep, version of pack.dependencies when dep.indexOf('mimosa-') > -1
    modPack = require("../../node_modules/#{dep}/package.json")
    meta.push
      name:    dep
      version: modPack.version
      site:    modPack.homepage
      desc:    modPack.description
      default: if builtIns.indexOf(dep) > -1 then "yes" else "no"
      dependencies: modPack.dependencies
    all.push(require dep)

discoverModules()

module.exports =
  all: all
  basic: [file, compilers]
  installedMetadata: meta
