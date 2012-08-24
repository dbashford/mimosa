fs = require 'fs'
path = require 'path'

jade = require 'jade'

util = require './util'
logger = require '../util/logger'
Watcher =  require './util/watcher'

build = (opts) =>
  if !opts.optimize and opts.removeCombined
    logger.warn "--removeCombined flag set without setting --optimize flag, ignoring --removeCombined"
    opts.removeCombined = false

  if opts.debug then logger.setDebug()
  logger.info "Beginning build"

  util.processConfig false, (config) =>
    config.optimize = opts?.optimize
    if opts.removeCombined then config.require.optimize.overrides.removeCombined = true
    compilers = util.fetchConfiguredCompilers config, false
    new Watcher config, compilers, false, _buildFinished

    _writeJade(config) if opts.jade

_writeJade = (config) ->
  logger.info "Attempting to compile index.jade"

  viewsPath = path.resolve config.watch.sourceDir, '..', 'views', 'index.jade'

  if fs.existsSync viewsPath

    opts =
      title:    "Mimosa"
      reload:   false
      optimize: config.optimize
      env:      "production"

    logger.debug("Compiling jade file at [[ #{viewsPath} ]]")
    logger.debug("With the following context data:\n#{JSON.stringify(opts, null, 2)}")

    jade.renderFile viewsPath, opts, (err, html) ->
      if err
        logger.warn "Error compiling/rendering jade template #{viewsPath}"
        logger.warn "Error: #{err}"
      else
        outPath = path.join config.watch.compiledDir, 'index.html'

        logger.debug("Writing html output to [[ #{outPath} ]]")

        fs.writeFile outPath, html, (err) ->
          if err
            logger.warn "Failed to write compiled jade template: #{err}"
          else
            logger.success "Successfully compiled and wrote compiled index.html file."
  else
    logger.warn "Cannot find #{viewsPath}, cannot compile the jade template."

_buildFinished = ->
  logger.success "Finished build"

register = (program, callback) =>
  program
    .command('build')
    .description("make a single pass through assets and compile them")
    .option("-o, --optimize", "run r.js optimization after building")
    .option("-r, --removeCombined", "removes all of the files involved in the optimization, leaving behind just the built files")
    .option("-j, --jade", "compile the provided jade template into an html, for those not deploying to node environment and in need of an html file")
    .option("-D, --debug", "run in debug mode")
    .action(callback)
    .on '--help', =>
      logger.green('  The build command will make a single pass through your assets and bulid any that need building')
      logger.green('  and then exit.')
      logger.blue( '\n    $ mimosa build\n')
      logger.green('  Pass an \'optimize\' flag and Mimosa will use requirejs to optimize your assets and provide you')
      logger.green('  with single files for the named requirejs modules. ')
      logger.blue( '\n    $ mimosa build --optimize')
      logger.blue( '    $ mimosa build -o\n')
      logger.green('  Pass a \'removeCombined\' flag in addition to the `--optimize` flag and Mimosa will ensure that')
      logger.green('  that all of the assets that go into the optimization are removed after the minified files are ')
      logger.green('  created.')
      logger.blue( '\n    $ mimosa build --optimize --removeCombined')
      logger.blue( '    $ mimosa build -o -r\n')
      logger.green('  Pass an \'jade\' flag and Mimosa will attempt to compile the jade template (index.jade) that comes')
      logger.green('  bundled with Mimosa\'s starter app created with the `new` command.  It will do so as if you were')
      logger.green('  deploying the resulting html to a production-like environment.  Live reload will not be included.')
      logger.green('  CSS will not be cache busted.  Use the \'jade\' command in conjunction with \'optimize\' to have')
      logger.green('  your resulting html primed to serve the optimized file.  This command will not work if you have')
      logger.green('  altered your index.jade file to take parameters other than those it originally was delivered to take.')
      logger.blue( '\n    $ mimosa build --jade')
      logger.blue( '    $ mimosa build -j\n')


module.exports = (program) ->
  register(program, build)