logger = require 'logmimosa'

config = (name, opts) ->

  unless name?
    return logger.error "Must provide a module name, ex: mimosa mod:config mimosa-moduleX"

  mod = getModule(name)
  unless mod?
    mod = getModule("mimosa-#{name}")

  if mod?
    if mod.placeholder
      text = mod.placeholder()
      logger.green "\n#{text}\n\n"
    else
      logger.info "Module [[ #{name} ]] has no configuration"
  else
    return logger.error "Could not find module named [[ #{name} ]]"

  process.exit 0

getModule = (name) ->
  try
    mod = require name
    return mod
  catch err
    logger.debug "Did not find module named [[ #{name} ]]"
  null

register = (program, callback) ->
  program
    .command('mod:config [name]')
    .option("-D, --debug", "run in debug mode")
    .description("Print out the configuration snippet for a module to the console")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:config command will print out the default commented out CoffeeScript snippet, ')
      logger.green('  for the given named Mimosa module, that you would need to include in your config to')
      logger.green('  begin using the module.')
      logger.blue( '\n    $ mimosa mod:config [nameOfModule]\n')


module.exports = (program) ->
  register program, config