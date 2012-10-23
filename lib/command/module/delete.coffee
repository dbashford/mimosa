path =   require 'path'
fs =     require 'fs'

logger = require 'mimosa-logger'

deleteMod = (opts) ->

register = (program, callback) ->
  program
    .command('config')
    .option("-D, --debug", "run in debug mode")
    .description("copy the default Mimosa config into the current folder")
    .action(callback)
    .on '--help', =>
      logger.green('  The config command will copy the default Mimosa config to the current directory.')
      logger.green('  There are no options for the config command.')
      logger.blue( '\n    $ mimosa config\n')

module.exports = (program) ->
  register program, deleteMod