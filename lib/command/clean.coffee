fs = require 'fs'
path = require 'path'

wrench = require 'wrench'

util = require './util'
logger = require '../util/logger'

clean = ->
  util.processConfig false, (config) =>
    srcDir = config.watch.sourceDir
    files = wrench.readdirSyncRecursive(srcDir)

    compilers = util.fetchConfiguredCompilers(config)
    compiler.cleanup() for compiler in compilers when compiler.cleanup?

    for file in files
      isDirectory = fs.statSync(path.join(srcDir, file)).isDirectory()
      continue if isDirectory

      compiledPath = path.join config.root, config.watch.compiledDir, file

      extension = path.extname(file)
      if extension?.length > 0
        extension = extension.substring(1)
        compiler = compilers.find (comp) ->
          for ext in comp.getExtensions()
            return true if extension is ext
          return false
        if compiler? and compiler.getOutExtension()
          compiledPath = compiledPath.replace(/\.\w+$/, ".#{compiler.getOutExtension()}")

      fs.unlinkSync compiledPath if fs.existsSync compiledPath

    directories = files.filter (f) -> fs.statSync(path.join(srcDir, f)).isDirectory()
    directories = directories.sortBy('length', true)
    for dir in directories
      dirPath = path.join(config.root, config.watch.compiledDir, dir)
      if fs.existsSync dirPath
        fs.rmdir dirPath, (err) ->
          if err?.code is not "ENOTEMPTY"
            logger.error "Unable to delete directory, #{dirPath}"
            logger.error err

    logger.success "#{path.join(config.root, config.watch.compiledDir)} has been cleaned."


register = (program, callback) =>
  program
    .command('clean')
    .description("clean out all of the compiled assets from the compiled directory")
    .action(callback)
    .on '--help', =>
      logger.green('  The clean command will remove all of the compiled assets from the configured compiledDir and ')
      logger.green('  any empty directories after the compiled assets are removed. It will also remove any Mimosa')
      logger.green('  copied assets, like template libraries. It will not remove anything that did not originate')
      logger.green('  from the source directory.')
      logger.blue( '\n    $ mimosa clean\n')

module.exports = (program) ->
  register(program, clean)