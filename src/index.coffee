program = require 'commander'
logger =  require 'logmimosa'

version = require('../package.json').version
program.version version

all = ->
  require('./command/new')(program)
  require('./command/watch')(program)
  require('./command/config')(program)
  require('./command/build')(program)
  require('./command/clean')(program)
  require('./command/external')(program)
  require('./command/module/install')(program)
  require('./command/module/uninstall')(program)
  require('./command/module/list')(program)
  require('./command/module/search')(program)
  require('./command/module/config')(program)

all()

if process.argv.length is 2 or (process.argv.length > 2 and process.argv[2] is '--help')
  process.argv[2] = '--help'
else
  program.command('*').action (arg) ->
    if arg then logger.red "  #{arg} is not a valid command."
    process.argv[2] = '--help'
    program.parse process.argv

program.parse process.argv
