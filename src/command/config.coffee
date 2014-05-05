copyConfig = (opts) ->
  path =   require 'path'
  fs =     require 'fs'
  logger = require 'logmimosa'
  buildConfig = require '../util/config-builder'
  moduleManager = require '../modules'

  if opts.mdebug
    opts.debug = true
    logger.setDebug()
    process.env.DEBUG = true

  conf = buildConfig()

  currDefaultsPath = path.join path.resolve(''), "mimosa-config-documented.coffee"
  logger.debug "Writing config defaults file to #{currDefaultsPath}"
  defaultsConf = """

                 # The following is a version of the mimosa-config with all of
                 # the defaults listed. This file is meant for reference only.

                 #{conf}
                 """

  fs.writeFileSync currDefaultsPath, defaultsConf, 'ascii'

  unless opts.suppress
    logger.success "Copied [[ mimosa-config-documented.coffee ]] into current directory."

  mimosaConfigPath = path.join path.resolve(''), "mimosa-config.js"
  mimosaConfigPathCoffee = path.join path.resolve(''), "mimosa-config.coffee"

  if fs.existsSync(mimosaConfigPath) or fs.existsSync(mimosaConfigPathCoffee)
    unless opts.suppress
      logger.info "Not writing mimosa-config file as one exists already."
  else
    logger.debug "Writing config file to #{mimosaConfigPath}"
    outConfigText = if moduleManager.configModuleString
      modArray = JSON.parse(moduleManager.configModuleString)
      modObj = modules:modArray
      "exports.config = " + JSON.stringify( modObj, null, 2 )
    else
      modObj = modules: ['copy', 'jshint', 'csslint', 'server', 'require', 'minify-js', 'minify-css', 'live-reload', 'bower']
      "exports.config = " + JSON.stringify( modObj, null, 2 )

    fs.writeFileSync mimosaConfigPath, outConfigText, 'ascii'

    unless opts.suppress
      logger.success "Copied [[ mimosa-config.js ]] into current directory."

  process.exit 0

register = (program, callback) ->
  program
    .command('config')
    .option("-D, --mdebug", "run in debug mode")
    .option("-s, --suppress", "suppress info message")
    .description("copy the default Mimosa config into the current folder")
    .action(callback)
    .on '--help', ->
      logger = require 'logmimosa'
      logger.green('  The config command will create a mimosa-config.js in the current directory. It will')
      logger.green('  also create a mimosa-config-documented.coffee which contains all of the various')
      logger.green('  configuration documentation for each module that is a part of your project.')
      logger.blue( '\n    $ mimosa config\n')

module.exports = (program) ->
  register(program, copyConfig)
