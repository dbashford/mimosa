util = require './util'
logger = require '../util/logger'
Watcher =  require './util/watcher'

build = (opts) =>
  logger.info "Beginning build"

  util.processConfig false, (config) =>
    config.optimize = opts?.optimize
    compilers = util.fetchConfiguredCompilers config, false
    new Watcher config, compilers, false, buildFinished

buildFinished = -> logger.success("Finished build")

register = (program, callback) =>
  program
    .command('build')
    .description("make a single pass through assets and compile them")
    .option("-o, --optimize", "run require.js optimization after building")
    .action(callback)
    .on '--help', =>
      logger.green('  The build command will make a single pass through your assets and bulid any that need building')
      logger.green('  and then exit.')
      logger.blue( '\n    $ mimosa build\n')
      logger.green('  Pass an \'optimize\' flag and Mimosa will use requirejs to optimize your assets and provide you')
      logger.green('  with single files for the named requirejs modules. ')
      logger.blue( '\n    $ mimosa build --optimize')
      logger.blue( '    $ mimosa build -o\n')

module.exports = (program) ->
  register(program, build)