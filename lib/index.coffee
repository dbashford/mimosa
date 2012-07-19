{exec} = require 'child_process'

program =  require 'commander'

version =  require('../package.json').version
logger =   require './util/logger'


class Mimosa

  constructor: ->
    program.version(version)

    require('./command/new')(program)
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/watch')(program)
    require('./command/virgin')(program)

    program.command('*')
      .action (arg) ->
        exec "mimosa --help", (error, stdout, stderr) ->
          logger.red "\n  #{arg} is not a valid command. \n"
          console.log stdout

    program.parse process.argv

module.exports = new Mimosa