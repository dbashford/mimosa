fs =     require 'fs'
path =   require 'path'

_ =      require 'lodash'
wrench = require 'wrench'

fileUtils = require '../util/file'
util =   require './util'
logger = require '../util/logger'

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
      items = wrench.readdirSyncRecursive(config.watch.sourceDir)
      files = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isFile()
      directories = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isDirectory()
      directories = _.sortBy(directories, 'length').reverse()

      compilers = util.fetchConfiguredCompilers(config)

      cleanMisc(config, compilers)
      cleanFiles(config, files, compilers)
      cleanDirectories(config, directories)

      logger.success "[[ #{config.watch.compiledDir} ]] has been cleaned."

cleanMisc = (config, compilers) ->
  jsDir = path.join config.watch.compiledDir, config.compilers.javascript.directory
  files = fileUtils.glob "#{jsDir}/**/*-built.js"
  for file in files
    logger.debug("Deleting '-built' file, [[ #{file} ]]")
    fs.unlinkSync file

  compiledJadeFile = path.join config.watch.compiledDir, 'index.html'
  if fs.existsSync compiledJadeFile
    logger.debug("Deleting compiledJadeFile [[ #{compiledJadeFile} ]]")
    fs.unlinkSync compiledJadeFile

  logger.debug("Calling individual compiler cleanups")
  compiler.cleanup() for compiler in compilers when compiler.cleanup?

cleanFiles = (config, files, compilers) ->
  for file in files
    compiledPath = path.join config.watch.compiledDir, file

    extension = path.extname(file)
    if extension?.length > 0
      extension = extension.substring(1)
      compiler = _.find compilers, (comp) ->
        for ext in comp.getExtensions()
          return true if extension is ext
        return false
      if compiler? and compiler.getOutExtension()
        compiledPath = compiledPath.replace(/\.\w+$/, ".#{compiler.getOutExtension()}")

    if fs.existsSync compiledPath
      logger.debug "Deleting file [[ #{compiledPath} ]]"
      fs.unlinkSync compiledPath

cleanDirectories = (config, directories) ->
  for dir in directories
    dirPath = path.join(config.watch.compiledDir, dir)
    if fs.existsSync dirPath
      logger.debug "Deleting directory [[ #{dirPath} ]]"
      fs.rmdir dirPath, (err) ->
        if err?.code is not "ENOTEMPTY"
          logger.error "Unable to delete directory, #{dirPath}"
          logger.error err

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