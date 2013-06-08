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
  require('./command/refresh')(program)
  require('./command/virgin')(program)
  require('./command/external')(program)
  require('./command/module/install')(program)
  require('./command/module/init')(program)
  require('./command/module/uninstall')(program)
  require('./command/module/list')(program)
  require('./command/module/search')(program)
  require('./command/module/config')(program)

if process.argv.length is 2 or (process.argv.length > 2 and process.argv[2] is '--help')
  process.argv[2] = '--help'
  all()
else
  if process.argv[2] is "new"
    require('./command/new')(program)
  else if process.argv[2].indexOf("mod:") is 0
    require('./command/module/install')(program)
    require('./command/module/init')(program)
    require('./command/module/uninstall')(program)
    require('./command/module/list')(program)
    require('./command/module/search')(program)
    require('./command/module/config')(program)
  else if process.argv[2] is "watch"
    require('./command/watch')(program)
  else
    require('./command/config')(program)
    require('./command/build')(program)
    require('./command/clean')(program)
    require('./command/refresh')(program)
    require('./command/virgin')(program)

    require('./command/external')(program)

    program.command('*').action (arg) ->
      if arg then logger.red "  #{arg} is not a valid command."
      process.argv[2] = '--help'
      all()
      program.parse process.argv

program.parse process.argv
