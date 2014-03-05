logger = require 'logmimosa'
_ = require 'lodash'

modules = require('../../modules/').installedMetadata

config = (name, opts) ->
  if opts.mdebug
    opts.debug = true
    logger.setDebug()
    process.env.DEBUG = true

  unless name?
    return logger.error "Must provide a module name, ex: mimosa mod:config mimosa-moduleX"

  modMeta = _.findWhere(modules, {name:name})
  if modMeta?
    mod = modMeta.mod
    if mod.placeholder
      text = mod.placeholder()
      logger.green "#{text}\n\n"
    else
      logger.info "Module [[ #{name} ]] has no configuration"
  else
    return logger.error "Could not find module named [[ #{name} ]]"

  process.exit 0

register = (program, callback) ->
  program
    .command('mod:config [name]')
    .option("-D, --mdebug", "run in debug mode")
    .description("Print out the configuration snippet for a module to the console")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:config command will print out the default CoffeeScript snippet for the')
      logger.green('  given named Mimosa module. If there is already a mimosa-config.coffee in the')
      logger.green('  current directory, Mimosa will not copy the file in.')
      logger.blue( '\n    $ mimosa mod:config [nameOfModule]\n')

module.exports = (program) ->
  register program, config
