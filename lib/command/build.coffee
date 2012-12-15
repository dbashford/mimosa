fs = require 'fs'
path = require 'path'

logger = require 'logmimosa'

util = require '../util/util'
Watcher =  require '../util/watcher'
Cleaner = require '../util/cleaner'

build = (opts) =>
  if opts.debug then logger.setDebug()
  logger.info "Beginning build"
  opts.build = true

  util.processConfig opts, (config, modules) =>
    doBuild = ->
      config.isClean = false
      new Watcher config, modules, false, ->
        logger.success "Finished build"
        process.exit 0

    config.isClean = true
    new Cleaner(config, modules, doBuild)

register = (program, callback) =>
  program
    .command('build')
    .description("make a single pass through assets, compile them, and optionally package them")
    .option("-o, --optimize", "run r.js optimization after building")
    .option("-m, --minify", "minify each asset as it is compiled using uglify")
    .option("-p, --package", "package code for distribution after the code has been built")
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
      logger.green('  Pass an \'minify\' flag and Mimosa will use uglify to minify/compress your assets when they are compiled.')
      logger.green('  You can provide exclude, files you do not want to minify, in the mimosa-config.  If you run \'minify\' ')
      logger.green('  and \'optimize\' at the same time, optimize will not run the uglify portion of its processing which occurs as')
      logger.green('  a separate step after everything has compiled and does not allow control of what gets uglified. Use \'optimize\'')
      logger.green('  and \'minify\' together if you need to control which files get mangled by uglify (because sometimes uglify')
      logger.green('  can break them) but you still want everything together in a single file.')
      logger.blue( '\n    $ mimosa watch --minify')
      logger.blue( '    $ mimosa watch -m\n')
      logger.green('  Pass a \'package\' flag if you have installed a module (like mimosa-web-package) that is capable of')
      logger.green('  executing packaging functionality for you after the building of assets is complete.')
      logger.blue( '\n    $ mimosa build --package')
      logger.blue( '    $ mimosa build -p\n')

module.exports = (program) ->
  register(program, build)