path = require 'path'
fs = require 'fs'

volo = require 'volo'
wrench = require 'wrench'

util =   require './util'
logger =   require '../util/logger'

class InstallCommand

  constructor: (@program) ->

  install: (args...) =>
    opts = @prepArgs(args)

    util.processConfig false, (config) =>
      dirs = @directories(config)

      logger.green "\n  In which directory would you like to install this library? \n"
      @program.choose dirs, (i) =>
        logger.info "Beginning install..."

        currentDir = process.cwd()
        desiredDir = dirs[i]
        fullDesiredDir = path.join config.watch.sourceDir, desiredDir
        process.chdir fullDesiredDir
        done = ->
          process.chdir(currentDir)
          process.stdin.destroy()

        @runVolo(args, desiredDir, config.compilers.javascript.directory, done)

  prepArgs: (args) ->
    args.unshift('add')                 # adding add
    opts = args.pop()                   # nuking commanders last parm
    args.push('-amd') unless opts.noamd
    args.push('-f')                     # forcing force =p
    opts

  runVolo: (args, destDirectory, jsDir, callback) ->
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
      fs.statSync(fullPath).isDirectory() and f.indexOf(config.compilers.javascript.directory) >= 0
    .sort()

  register: =>
    @program
      .command('install')
      .description("install libraries from github via the command line")
      .option("-n, --noamd",  "will load the non-amd version")
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