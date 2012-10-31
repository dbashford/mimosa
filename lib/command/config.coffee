path =   require 'path'
fs =     require 'fs'

logger = require 'logmimosa'
configurer = require '../util/configurer'

copyConfig = (opts) ->
  if opts.debug then logger.setDebug()

  configText = configurer.buildConfigText()
  currPath = path.join path.resolve(''), "mimosa-config.coffee"
  logger.debug "Writing config file to #{currPath}"
  fs.writeFileSync currPath, configText, 'ascii'
  logger.success "Copied default config file into current directory."
  process.exit 1

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
  register(program, copyConfig)