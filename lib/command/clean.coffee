fs =      require 'fs'
path   =  require 'path'

wrench =  require 'wrench'
_      =  require 'lodash'
logger =  require 'mimosa-logger'

util =    require './util'

clean = (opts) ->
  if opts.debug then logger.setDebug()

  util.processConfig opts, (config) =>
    if opts.force
      if fs.existsSync config.watch.compiledDir
        logger.info "Forcibly removing the entire directory [[ #{config.watch.compiledDir} ]]"
        wrench.rmdirSyncRecursive(config.watch.compiledDir)
        logger.success "[[ #{config.watch.compiledDir} ]] has been removed"
      else
        logger.success "Compiled directory already deleted"
    else
      config.isClean = true
      util.cleanCompiledDirectories config, ->
        logger.success "[[ #{config.watch.compiledDir} ]] has been cleaned."

register = (program, callback) =>
  program
    .command('clean')
    .option("-f, --force", "completely delete your compiledDir")
    .option("-D, --debug", "run in debug mode")
    .description("clean out all of the compiled assets from the compiled directory")
    .action(callback)
    .on '--help', =>
      logger.green('  The clean command will remove all of the compiled assets from the configured compiledDir. After')
      logger.green('  the assets are deleted, any empty directories left over are also removed. Mimosa will also remove any')
      logger.green('  Mimosa copied assets, like template libraries. It will not remove anything that did not originate')
      logger.green('  from the source directory.')
      logger.blue( '\n    $ mimosa clean\n')
      logger.green('  In the course of development, some files get left behind that no longer have counterparts in your')
      logger.green('  source directories.  If you have \'mimosa watch\' turned off when you delete a file, for instance,')
      logger.green('  the compiled version of that file will not get removed from your compiledDir, and \'mimosa clean\'')
      logger.green('  will leave it alone because it does not recognize it as coming from mimosa.  If you want to ')
      logger.green('  forcibly remove the entire compiledDir, use the \'force\' flag.')
      logger.blue( '\n    $ mimosa clean -force')
      logger.blue( '    $ mimosa clean -f\n')

module.exports = (program) ->
  register(program, clean)