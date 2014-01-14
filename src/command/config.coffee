path =   require 'path'
fs =     require 'fs'

logger = require 'logmimosa'
buildConfig = require '../util/config-builder'

copyConfig = (opts) ->
  if opts.mdebug
    opts.debug = true
    logger.setDebug()
    process.env.DEBUG = true

  conf = buildConfig()

  currDefaultsPath = path.join path.resolve(''), "mimosa-config-documented.coffee"
  logger.debug "Writing config defaults file to #{currDefaultsPath}"
  defaultsConf = """

                 # THE FOLLOWING IS A COMMENTED VERSION OF THE mimosa-config.coffee WITH
                 # ALL OF THE MOST RECENT DEFAULTS. THIS FILE IS MEANT FOR REFERENCE ONLY.

                 #{conf}
                 """

  fs.writeFileSync currDefaultsPath, defaultsConf, 'ascii'
  logger.success "Copied mimosa-config-commented.coffee into current directory."

  mimosaConfigPath = path.join path.resolve(''), "mimosa-config.js"
  if fs.existsSync mimosaConfigPath
    unless opts.suppress
      logger.info "Not writing mimosa-config.js file as one exists already."
  else
    logger.debug "Writing config file to #{mimosaConfigPath}"
    outConfigText = "exports.config = " + JSON.stringify( conf, null, 2 )
    fs.writeFileSync mimosaConfigPath, outConfigText, 'ascii'
    logger.success "Copied mimosa-config.js into current directory."

  process.exit 0

register = (program, callback) ->
  program
    .command('config')
    .option("-D, --mdebug", "run in debug mode")
    .option("-s, --suppress", "suppress info message")
    .description("copy the default Mimosa config into the current folder")
    .action(callback)
    .on '--help', =>
      logger.green('  The config command will copy the default Mimosa config to the current directory.')
      logger.green('  And also copy a defaults file to keep as reference should you desire to alter and.')
      logger.green('  shrink the mimosa-config.')
      logger.blue( '\n    $ mimosa config\n')

module.exports = (program) ->
  register(program, copyConfig)