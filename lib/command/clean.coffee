fs =     require 'fs'
path =   require 'path'

_ =      require 'lodash'
wrench = require 'wrench'
glob =   require 'glob-whatev'

util =   require './util'
logger = require '../util/logger'

clean = ->
  util.processConfig false, (config) =>
    items = wrench.readdirSyncRecursive(config.watch.sourceDir)
    files = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isFile()
    directories = items.filter (f) -> fs.statSync(path.join(config.watch.sourceDir, f)).isDirectory()
    directories = _.sortBy(directories, 'length').reverse()

    compilers = util.fetchConfiguredCompilers(config)

    cleanMisc(config, compilers)
    cleanFiles(config, files, compilers)
    cleanDirectories(config, directories)

    logger.success "#{config.watch.compiledDir} has been cleaned."

cleanMisc = (config, compilers) ->
  jsDir = path.join config.watch.compiledDir, config.compilers.javascript.directory
  files = glob.glob "#{jsDir}/**/*-built.js"
  fs.unlinkSync file for file in files

  compiledJadeFile = path.join config.watch.compiledDir, 'index.html'
  fs.unlinkSync compiledJadeFile if fs.existsSync compiledJadeFile

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

    fs.unlinkSync compiledPath if fs.existsSync compiledPath

cleanDirectories = (config, directories) ->
  for dir in directories
    dirPath = path.join(config.watch.compiledDir, dir)
    if fs.existsSync dirPath
      fs.rmdir dirPath, (err) ->
        if err?.code is not "ENOTEMPTY"
          logger.error "Unable to delete directory, #{dirPath}"
          logger.error err

register = (program, callback) =>
  program
    .command('clean')
    .description("clean out all of the compiled assets from the compiled directory")
    .action(callback)
    .on '--help', =>
      logger.green('  The clean command will remove all of the compiled assets from the configured compiledDir. After')
      logger.green('  the assets are deleted, any empty directories left over are also removed. Mimosa will also remove any')
      logger.green('  Mimosa copied assets, like template libraries. It will not remove anything that did not originate')
      logger.green('  from the source directory.')
      logger.blue( '\n    $ mimosa clean\n')

module.exports = (program) ->
  register(program, clean)