path = require 'path'
fs = require 'fs'

volo = require 'volo'
wrench = require 'wrench'
logger = require 'logmimosa'

util = require '../util/util'

class ImportCommand

  constructor: (@program) ->

  import: (args...) =>
    unless typeof args[0] is 'string'
      return logger.error "You must provide a name of a library to import."

    @prepArgs(args)

    util.processConfig {}, (config, modules) =>
      dirs = @directories(config)
      logger.debug "All directories found:\n#{dirs.join('\n')}"

      logger.green "\n  Into which directory would you like to import this library? \n"
      @program.choose dirs, (i) =>
        logger.blue "\n  You chose #{dirs[i]}. \n"
        logger.info "Beginning import..."

        currentDir = process.cwd()
        desiredDir = dirs[i]
        fullDesiredDir = path.join config.watch.sourceDir, desiredDir

        logger.debug "Changing directory to [[ #{fullDesiredDir} ]]"
        process.chdir fullDesiredDir
        done = ->
          logger.debug "Removing package.json placed in [[ #{fullDesiredDir} ]]"
          fs.unlinkSync 'package.json' if fs.existsSync 'package.json'

          logger.debug "And changing directory back to [[ #{currentDir} ]]"
          process.chdir(currentDir)
          process.stdin.destroy()

        @runVolo(args, desiredDir, config.watch.javascriptDir, done)

  prepArgs: (args) ->
    args.unshift('add')                 # adding add
    opts = args.pop()                   # nuking commanders last parm
    if opts.debug then logger.setDebug()
    args.push('-amd') unless opts.noamd
    args.push('-f')                     # forcing force =p

  runVolo: (args, destDirectory, jsDir, callback) ->
    logger.debug "Running volo with the following args:\n#{JSON.stringify(args, null, 2)}"
    volo(args).then (okText) ->
      dependencyName = destDirectory.replace(jsDir, '').replace(path.sep, '')
      okText = okText.replace /\s+at\s+([^\s]+)/g, (a, b) ->
        " at #{path.join(destDirectory,b)}"
      okText = okText.replace /\s+name:\s+([^\s]+)/g, (a, b) ->
        " name: #{path.join(dependencyName,b)}"
      logger.success "#{okText}\nImport Complete!"
      callback()
    , (errText) ->
      logger.error errText
      callback()

  directories: (config) ->
    items = wrench.readdirSyncRecursive(config.watch.sourceDir)
    items.filter (f) ->
      fullPath = path.join config.watch.sourceDir, f
      fs.statSync(fullPath).isDirectory() and f.indexOf(config.watch.javascriptDir) >= 0
    .sort()

  register: =>
    @program
      .command('import')
      .description("import libraries from github via the command line using volo")
      .option("-n, --noamd",  "will load the non-amd version")
      .option("-D, --debug", "run in debug mode")
      .action(@import)
      .on '--help', ->
        logger.green('  This command exposes basic volo (http://volojs.org/) functionality to import and install')
        logger.green('  libraries from GitHub.  Mimosa will ask you where you\'d like to import the library.  Then')
        logger.green('  your library will be fetched from GitHub and placed in the directory you chose.  Mimosa')
        logger.green('  will also fetch any dependent libraries.  For instance, if you import Backbone it will')
        logger.green('  also import jquery and underscore.')
        logger.blue( '\n    $ mimosa import backbone\n')
        logger.green('  Mimosa assumes you want an AMD version of the library you are attempting to fetch and will')
        logger.green('  attempt to find that.  Should a non-AMD library be found, you will be asked to provide details')
        logger.green('  regarding dependencies and and export information.\n')
        logger.green('  Should you not want an AMD version, you can provide the \'import\' command with a --noamd')
        logger.green('  flag.  In this case an AMD version will not be sought, and a non-AMD version will not trigger ')
        logger.green('  a list of questions.')
        logger.blue( '\n    $ mimosa import backbone --noamd')
        logger.blue( '    $ mimosa import backbone -n\n')

module.exports = (program) ->
  command = new ImportCommand(program)
  command.register()