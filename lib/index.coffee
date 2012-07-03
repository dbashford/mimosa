require 'sugar'

program =  require 'commander'

version =  require('../package.json').version
logger =   require './util/logger'

{exec} = require 'child_process'

class Mimosa

  constructor: ->
    program.version(version)

    require('./command/new')(program)
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/watch')(program)

    program.command('*')
      .action (arg) ->
        exec "mimosa --help", (error, stdout, stderr) ->
          console.log()
          logger.red "  #{arg} is not a valid command."
          console.log stdout

    program.parse process.argv

module.exports = new Mimosa