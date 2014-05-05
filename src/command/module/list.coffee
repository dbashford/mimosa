http = require 'http'

color  = require('ansi-color').set
logger = require 'logmimosa'
childProcess = require 'child_process'

moduleMetadata = require('../../modules').installedMetadata

printResults = (mods, opts) ->
  verbose = opts.verbose
  installed = opts.installed

  longestModName = 0
  ownedMods = []
  for mod in mods
    if mod.name.length > longestModName
      longestModName = mod.name.length
    mod.installed= ''
    for m in moduleMetadata
      if m.name is mod.name
        if mod.version is m.version
          mod.installed = m.version
        else
          mod.installed = color m.version, "red"
          mod.site = color "      "+mod.site, "green+bold"
        ownedMods.push mod

  mods = mods.filter (mod) ->
    for owned in ownedMods
      if owned.name is mod.name
        return false
    true

  mods = if installed
    logger.green "  The following is a list of the Mimosa modules currently installed.\n"
    ownedMods
  else
    logger.green "  The following is a list of the Mimosa modules in NPM.\n"
    ownedMods.concat mods

  gap = new Array(longestModName-2).join(' ')

  logger.blue "  Name" + gap + "Version     Updated              Have?       Website"
  fields = [
    ['name',longestModName + 2],
    ['version',13],
    ['updated',22],
    ['installed',13],
    ['site',65],
  ]
  for mod in mods
    headline = "  "
    for field in fields
      name = field[0]
      spacing = field[1]
      data = mod[name]
      headline += data
      spaces = spacing - (data + "").length
      if spaces < 1 then spaces = 2
      headline += new Array(spaces).join(' ')

    logger.green headline

    if verbose
      console.log "  Description:  #{mod.desc}"
      if mod.dependencies?
        asArray = for dep, version of mod.dependencies
          "#{dep}@#{version}"
        console.log "  Dependencies: #{asArray.join(', ')}"
      console.log ""

  unless verbose
    logger.green "\n  To view more module details, execute \'mimosa mod:search -v\' for \'verbose\' logging."

  unless installed
    logger.green "\n  To view only the installed Mimosa modules, add the [-i/--installed] flag: \'mimosa mod:list -i\'"

  logger.green "  \n  Install modules by executing \'mimosa mod:install <<name of module>>\' \n\n"

  process.exit 0

list = (opts) ->
  if opts.mdebug
    opts.debug = true
    logger.setDebug()
    process.env.DEBUG = true

  logger.green "\n  Searching Mimosa modules...\n"

  childProcess.exec 'npm config get proxy', (error, stdout, stderr) ->
    options = {
      'uri': 'http://mimosa-data.herokuapp.com/modules'
    }
    proxy = stdout.replace /(\r\n|\n|\r)/gm, ''
    if !error && proxy != 'null'
      options.proxy = proxy
    request = require 'request'
    request options, (error, client, response) ->
      if error != null
        console.log(error)
        return
      mods = JSON.parse response
      printResults mods, opts

register = (program, callback) ->
  program
    .command('mod:list')
    .option("-D, --mdebug", "run in debug mode")
    .option("-v, --verbose", "list more details about each module")
    .option("-i, --installed", "Show just those modules that are currently installed.")
    .description("get list of all mimosa modules in NPM")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:list command will search npm for all packages and return a list')
      logger.green('  of Mimosa modules that are available for install. This command will also')
      logger.green('  inform you if your project has out of date modules.')
      logger.blue( '\n    $ mimosa mod:list\n')
      logger.green('  Pass an \'installed\' flag to only see the modules you have installed.')
      logger.blue( '\n    $ mimosa mod:list --installed\n')
      logger.blue( '\n    $ mimosa mod:list -i\n')
      logger.green('  Pass a \'verbose\' flag to get additional information about each module')
      logger.blue( '\n    $ mimosa mod:list --verbose\n')
      logger.blue( '\n    $ mimosa mod:list -v\n')

module.exports = (program) ->
  register program, list