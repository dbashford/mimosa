path =   require 'path'
fs =     require 'fs'

logger = require 'logmimosa'
moduleMetadata = require('../../modules').installedMetadata

list = (opts) ->
  if opts.debug then logger.setDebug()

  logger.green "\n  The following is a list of the Mimosa modules you have installed.\n"
  logger.blue "  Name                      Version         Website"
  fields = [
    ['name',25],
    ['version',15],
    ['site',65],
  ]
  for mod in moduleMetadata
    headline = "  "
    for field in fields
      name = field[0]
      spacing = field[1]
      data = mod[name]
      headline += data
      spaces = spacing - (data + "").length
      if spaces < 1 then spaces = 2
      headline += " " for n in [0..spaces]

    logger.green headline

    if opts.verbose
      console.log "  Description:  #{mod.desc}"
      if mod.dependencies?
        asArray = for dep, version of mod.dependencies
          "#{dep}@#{version}"
        console.log "  Dependencies: #{asArray.join(', ')}"
      console.log ""

  unless opts.verbose
    logger.green "\n  To view more module details, execute \'mimosa mod:search -v\' for \'verbose\' logging. \n"

register = (program, callback) ->
  program
    .command('mod:list')
    .option("-D, --debug", "run in debug mode")
    .option("-v, --verbose", "list more details about each module")
    .description("list all of your currently installed Mimosa modules")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:list command will list all of the Mimosa modules you currently have installed')
      logger.green('  and include information like version, a description, and where the module can be found')
      logger.green('  so you can read up on it.')
      logger.blue( '\n    $ mimosa mod:list\n')
      logger.green('  Pass a \'verbose\' flag to get additional information about each module')
      logger.blue( '\n    $ mimosa mod:list --verbose\n')
      logger.blue( '\n    $ mimosa mod:list -v\n')

module.exports = (program) ->
  register program, list