path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench = require 'wrench'
glob =  require 'glob'

logger = require '../util/logger'

class NewCommand

  constructor: (@program) ->

  register: =>
    @program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-n, --noexpress", "do not include express in the application setup")
      .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults")
      .action(@create)
      .on '--help', @printHelp

  create: (name, opts) =>
    skeletonPath = path.join __dirname, '..', 'skeleton'

    # if name provided, simply copy directory into directory by that name
    # if name not provided, copy all skeleton contents into current directory
    @currPath = if name?.length > 0
      @copySkeletonToProvidedDirectory(skeletonPath, name)
    else
      @copySkeletonToCurrentDirectory(skeletonPath)

    @postCopyCleanUp()

    if opts.noexpress then @usingDefaultServer() else @usingExpress()

  copySkeletonToProvidedDirectory: (skeletonPath, name) ->
    currPath = path.join path.resolve(''), name
    logger.info "Copying skeleton project into #{currPath}"
    wrench.copyDirSyncRecursive skeletonPath, currPath
    currPath

  copySkeletonToCurrentDirectory: (skeletonPath) ->
    logger.info "A project name was not provided, copying skeleton into the current directory"
    currPath = path.join path.resolve(''), '/'
    skeletonContents = wrench.readdirSyncRecursive(skeletonPath)
    for item in skeletonContents
      fullSourcePath = path.join skeletonPath, item
      fileStats = fs.statSync fullSourcePath
      if fileStats.isDirectory()
        wrench.mkdirSyncRecursive path.join(currPath, item), 0o0777
      if fileStats.isFile()
        fileContents = fs.readFileSync fullSourcePath
        fs.writeFileSync path.join(currPath, item), fileContents
    currPath

  postCopyCleanUp: =>
    # for some reason I can't quite figure out
    # won't copy over a public directory, so hack it out here
    newPublicPath = path.join @currPath, 'public'
    oldPublicPath = path.join @currPath, 'publicc'
    fs.renameSync oldPublicPath, newPublicPath

    glob "#{@currPath}/**/.gitkeep", (err, files) ->
      fs.unlinkSync(file) for file in files

  # remove express files/directories and update config to point to default server
  usingDefaultServer: ->
    fs.unlinkSync path.join(@currPath, "server.coffee")
    fs.unlinkSync path.join(@currPath, "package.json")
    wrench.rmdirSyncRecursive path.join(@currPath, "views")
    wrench.rmdirSyncRecursive path.join(@currPath, "routes")

    logger.info "Altering configuration to not use express"
    configPath = path.join @currPath, "mimosa-config.coffee"
    fs.readFile configPath, "ascii", (err, data) =>
      data = data.replace "# server:", "server:"
      data = data.replace "# useDefaultServer: false", "useDefaultServer: true"
      fs.writeFile configPath, data, @done

  usingExpress: ->
    logger.info "Installing node modules "
    currentDir = process.cwd()
    process.chdir @currPath
    exec "npm install", (err, sout, serr) =>
      process.chdir currentDir
      @done()

  done: ->
    logger.success "New project creation complete!"
    logger.success "Execute 'mimosa watch --server' from inside your project to monitor the file system. then start coding!"

  printHelp: ->
    logger.green('  The new command will create a directory using the name provided, and place a default project skeleton')
    logger.green('  inside of it.  That project skeleton will by default include an basic Express app, with sample routes')
    logger.green('  and views.  It will also include some sample assets (CoffeeScript, SASS, Handlebars) to get you started.')
    console.log()
    logger.blue( '    $ mimosa new [nameOfProject]')
    console.log()
    logger.green('  If you wish to copy the project skeleton into your current directory, leave off the name.')
    console.log()
    logger.blue( '    $ mimosa new')
    console.log()
    logger.green('  Pass a \'noexpress flag\' to not include the basic Express app.  With this set up, if you choose to have')
    logger.green('  Mimosa serve up your assets, it will do so with an embedded Mimosa Express app, and not with one inside')
    logger.green('  your project')
    console.log()
    logger.blue( '    $ mimosa new [name] --noexpress')
    logger.blue( '    $ mimosa new --noexpress')
    logger.blue( '    $ mimosa new [name] -n')
    logger.blue( '    $ mimosa new -n')
    console.log()

module.exports = (program) ->
  command = new NewCommand(program)
  command.register()