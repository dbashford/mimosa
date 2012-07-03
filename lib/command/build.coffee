util = require './util'
logger = require '../util/logger'
Watcher =  require '../watch/watcher'

build = (opts) =>
  logger.info "Beginning build"

  util.processConfig false, (config) =>
    if opts.optimize then config.require.forceOptimization = true
    compilers = util.fetchCompilers config, false
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
      console.log()
      logger.blue( '    $ mimosa build')
      console.log()
      logger.green('  Pass an optimize flag and Mimosa will use requirejs to optimize your assets and provide you with')
      logger.green('  single files for the named requirejs modules. ')
      console.log()
      logger.blue( '    $ mimosa build --optimize')
      logger.blue( '    $ mimosa build -o')
      console.log()


module.exports = (program) ->
  register(program, build)