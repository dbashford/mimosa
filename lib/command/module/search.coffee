path =   require 'path'
fs =     require 'fs'

color  = require('ansi-color').set
logger = require 'logmimosa'
npm = require 'npm'

moduleMetadata = require('../../modules').installedMetadata

printResults = (mods, verbose) ->
  logger.green "  The following is a list of the Mimosa modules in NPM.\n"
  logger.blue "  Name                      Version         Updated                Installed?   Website"
  fields = [
    ['name',25],
    ['version',15],
    ['updated',22],
    ['installed',12],
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
      headline += " " for n in [0..spaces]

    logger.green headline

    if verbose
      console.log "  Description:  #{mod.desc}"
      if mod.dependencies?
        asArray = for dep, version of mod.dependencies
          "#{dep}@#{version}"
        console.log "  Dependencies: #{asArray.join(', ')}"
      console.log ""

  unless verbose
    logger.green "\n  To view more module details, execute \'mimosa mod:search -v\' for \'verbose\' logging. \n"

  logger.green "  Install modules by executing \'mimosa mod:install <<name of module>>\' \n"

  process.exit 0

search = (opts) ->
  logger.green "\n  Searching NPM for Mimosa modules, this might take a few seconds...\n"
  npm.load { outfd: null, exit: false, loglevel:'silent' }, ->
    npm.commands.search ['mimosa-'], true, (err, pkgs) ->
      if err
        logger.error "Problem accessing NPM: #{err}"
      else
        packageNames = Object.keys(pkgs)
        mods = []
        i = 0
        add = (mod) ->
          mods.push mod
          printResults(mods, opts.verbose) if ++i is packageNames.length

        packageNames.forEach (pkg) ->
          npm.commands.view [pkg], true, (err, packageInfo) ->
            for version, data of packageInfo
              installed = false
              for m in moduleMetadata
                if m.name is data.name
                  installed = true
                  break

              mod =
                name:         data.name
                version:      version
                site:         data.homepage
                dependencies: data.dependencies
                desc:         data.description
                updated:      data.time[version].replace('T', ' ').replace(/\.\w+$/,'')
                installed:    if installed then "yes" else "no"
              add(mod)

register = (program, callback) ->
  program
    .command('mod:search')
    .option("-D, --debug", "run in debug mode")
    .description("get list of all mimosa modules in NPM")
    .option("-v, --verbose", "list more details about each module")
    .action(callback)
    .on '--help', =>
      logger.green('  The mod:search command will search npm for all packages using the keyword \'mmodule\'')
      logger.green('  and return a list of all the modules that are available for install.')
      logger.blue( '\n    $ mimosa mod:search\n')
      logger.green('  Pass a \'verbose\' flag to get additional information about each module')
      logger.blue( '\n    $ mimosa mod:search --verbose\n')
      logger.blue( '\n    $ mimosa mod:search -v\n')

module.exports = (program) ->
  register program, search