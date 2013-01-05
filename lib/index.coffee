program = require 'commander'
logger =  require 'logmimosa'

version = require('../package.json').version

external = require('./command/external')

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

    external(program)

    program.command('*').action (arg) ->
      if arg then logger.red "  #{arg} is not a valid command."
      process.argv[2] = '--help'
      program.parse process.argv

    program.parse process.argv

module.exports = new Mimosa()
