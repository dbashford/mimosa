path = require 'path'
fs = require 'fs'

volo = require 'volo'
wrench = require 'wrench'
logger =   require 'mimosa-logger'

util =   require './util'

class InstallCommand

  constructor: (@program) ->

  install: (args...) =>
    @prepArgs(args)

    util.processConfig {}, (config) =>
      dirs = @directories(config)
      logger.debug "All directories found:\n#{dirs.join('\n')}"

      logger.green "\n  In which directory would you like to install this library? \n"
      @program.choose dirs, (i) =>
        logger.blue "\n  You chose #{dirs[i]}. \n"
        logger.info "Beginning install..."

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
      logger.success "#{okText}\nInstall Complete!"
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
      .command('install')
      .description("install libraries from github via the command line")
      .option("-n, --noamd",  "will load the non-amd version")
      .option("-D, --debug", "run in debug mode")
      .action(@install)
      .on '--help', ->
        logger.green('  This command exposes basic volo (http://volojs.org/) functionality to install libraries')
        logger.green('  from GitHub.  Mimosa will ask you where you\'d like to install the library.  Then your')
        logger.green('  library will be fetched from GitHub and placed in the directory you chose.  Mimosa will')
        logger.green('  also fetch any dependent libraries.  For instance, if you install Backbone it will also')
        logger.green('  install jquery and underscore.')
        logger.blue( '\n    $ mimosa install backbone\n')
        logger.green('  Mimosa assumes you want an AMD version of the library you are attempting to fetch and will')
        logger.green('  attempt to find that.  Should a non-AMD library be found, you will be asked to provide details')
        logger.green('  regarding dependencies and and export information.\n')
        logger.green('  Should you not want an AMD version, you can provide the \'install\' command with a --noamd')
        logger.green('  flag.  In this case an AMD version will not be sought, and a non-AMD version will not trigger ')
        logger.green('  a list of questions.')
        logger.blue( '\n    $ mimosa install backbone --noamd')
        logger.blue( '    $ mimosa install backbone -n\n')

module.exports = (program) ->
  command = new InstallCommand(program)
  command.register()