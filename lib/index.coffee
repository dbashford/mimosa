program =  require 'commander'

version =  require('../package.json').version
logger =   require './util/logger'

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
    require('./command/update')(program)
    require('./command/install')(program)
    program.command('*').action (arg) ->
      if arg then logger.red "  #{arg} is not a valid command."
      process.argv[2] = '--help'
      program.parse process.argv

    program.parse process.argv

module.exports = new Mimosa()
