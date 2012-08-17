{exec} = require 'child_process'

program =  require 'commander'

version =  require('../package.json').version
logger =   require './util/logger'

class Mimosa

  constructor: ->
    return @printHelp() if process.argv.length is 2

    program.version(version)
    require('./command/new')(program)
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/watch')(program)
    require('./command/virgin')(program)
    require('./command/update')(program)
    require('./command/install')(program)
    program.command('*').action @printHelp

    program.parse process.argv

  printHelp: (arg) ->
    exec "mimosa --help", (error, stdout, stderr) ->
      if arg then logger.red "\n  #{arg} is not a valid command."
      logger.green stdout

module.exports = new Mimosa()