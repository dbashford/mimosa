program = require 'commander'
logger =  require 'logmimosa'

version = require('../package.json').version
program.version version

# require in config to determine modules
#   or ask configurer for modules in config
#   possibly just build config up front, allow flag adding
#   afterwards.
# require('./modules).configured()
# allow configuredModules to be easily accessed post creation
# refactor all async w/callback out of configurer among other places
#

require('./command/new')(program)
require('./command/watch')(program)
require('./command/config')(program)
require('./command/build')(program)
require('./command/clean')(program)
require('./command/external')(program)
require('./command/module/install')(program)
require('./command/module/uninstall')(program)
require('./command/module/list')(program)
require('./command/module/config')(program)

if process.argv.length is 2 or (process.argv.length > 2 and process.argv[2] is '--help')
  process.argv[2] = '--help'
else
  program.command('*').action (arg) ->
    if arg then logger.red "  #{arg} is not a valid command."
    process.argv[2] = '--help'
    program.parse process.argv

program.parse process.argv
