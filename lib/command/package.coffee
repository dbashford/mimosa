fs = require 'fs'
path = require 'path'

util = require './util'
logger = require '../util/logger'
Watcher =  require './util/watcher'

build = (opts) =>
  if opts.debug then logger.setDebug()

  logger.info "Beginning build"

  util.processConfig opts, (config) =>
    compilers = util.fetchConfiguredCompilers config, false
    new Watcher config, compilers, false, _buildFinished

_buildFinished = ->
  logger.success "Finished build"

register = (program, callback) =>
  program
    .command('package')
    .description("compile and optimize assets and ready them for delivery")
    .option("-D, --debug", "run in debug mode")
    .action(callback)
    .on '--help', =>
      logger.green('  The package command will make a single pass through your assets, bulid any that need building ')
      logger.green('  and output only the optimized versions to the "package" folder at the root of your project.')
      logger.green('  Mimosa will not leave behind any assets that have been optimized into other places.  For instance')
      logger.green('  any files that have been combined and minified by the optimizer will be removed.')
      logger.blue( '\n    $ mimosa package\n')


module.exports = (program) ->
  register(program, build)