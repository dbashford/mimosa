logger =   require 'logmimosa'

configurer = require '../util/configurer'
Watcher =  require '../util/watcher'

virgin = (opts) =>

  logger.warn """
The virgin command has been deprecated and will be removed in a future release.
If you use the virgin command and rather it not be removed, please travel over to
https://github.com/dbashford/mimosa/issues/198 and let me know that you'd like
to keep it.
  """

  if opts.debug
    logger.setDebug()
    process.env.DEBUG = true

  opts.virgin = true
  configurer opts, (config, modules) ->
    new Watcher(config, modules, true)

register = (program, callback) =>
  program
    .command('virgin')
    .option("-D, --debug", "run in debug mode")
    .option("-P, --profile <profileName>", "select a mimosa profile")
    .description("compile and lint assets but do not write the output")
    .action(callback)
    .on '--help', ->
      logger.green('  Mimosa without the extra kick.  The virgin command will observe your source directory, compile your')
      logger.green('  assets when they change, and lint the output, but it will not write the result, start a server or ')
      logger.green('  perform any RequireJS optimizations.  Use this is if you already have a server and an "asset pipeline",')
      logger.green('  but want the instant compilation feedback and the linting.')
      logger.blue( '\n    $ mimosa virgin\n')
      logger.green('  Pass a \'profile\' flag and the name of a Mimosa profile to run with mimosa config overrides from a profile.')
      logger.blue( '\n    $ mimosa clean --profile build')
      logger.blue( '    $ mimosa clean -P build')

module.exports = (program) ->
  register(program, virgin)