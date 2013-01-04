program = require 'commander'
logger =  require 'logmimosa'

modules = require './modules'
util =    require './util/util'

version = require('../package.json').version

class Mimosa

  constructor: ->
    process.argv[2] = '--help' if process.argv.length is 2
    program.version(version)

    require('./command/new')(program)
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/watch')(program)
    require('./command/virgin')(program)
    require('./command/refresh')(program)

    require('./command/module/install')(program)
    require('./command/module/init')(program)
    require('./command/module/uninstall')(program)
    require('./command/module/list')(program)
    require('./command/module/search')(program)
    require('./command/module/config')(program)

    @registerModuleCommands(program)

    program.command('*').action (arg) ->
      if arg then logger.red "  #{arg} is not a valid command."
      process.argv[2] = '--help'
      program.parse process.argv

    program.parse process.argv

  registerModuleCommands: (program) ->
    commandMods = modules.modulesWithCommands()

    #logger.info "There are #{commandMods.length} command mods"

    for mod in commandMods
      mod.registerCommand program, (callback) ->
        util.processConfig {}, (config) =>
          callback(config)

module.exports = new Mimosa()
