path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench = require 'wrench'
glob =  require 'glob'

logger = require '../util/logger'
util = require './util'
defaults = require './util/defaults'

class NewCommand

  constructor: (@program) ->

  register: =>
    @program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-n, --noserver", "do not include express in the application setup")
      .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults (CoffeeScript, SASS, Handlebars)")
      .action(@controller)
      .on '--help', @printHelp

  controller: (name, opts) =>
    return @_create(name, opts) if opts.defaults

    logger.green "\n  This is the Mimosa interactive project creation tool.  You will be prompted to choose the "
    logger.green "  meta-languages you'd like to use.  Mimosa will your scan project source directory for files "
    logger.green "  matching your selections and compile them as they change.  If you intend to use a meta-language"
    logger.green "  that is not listed, choose 'None', and then add a github issue"
    logger.green "  (https://github.com/dbashford/mimosa/issues) and we'll look at adding it. \n"

    util.gatherCompilerInfo (compilerInfo) =>

      compilerPrettyNames = {}
      for type, compilers of compilerInfo
        compilerPrettyNames[type] = compilers.map (compiler) -> compiler.prettyName

      chosenCompilers = {}

      logger.green "\n  To start, please choose your JavaScript meta-language: \n"
      @program.choose compilerPrettyNames.javascript, (i) =>
        logger.blue "\n  You chose #{compilerPrettyNames.javascript[i]}."
        logger.green "\n  Now choose your CSS meta-language:\n"
        comp = (compilerInfo.javascript.filter (item) => item.prettyName is compilerPrettyNames.javascript[i])[0]
        chosenCompilers.javascript = comp.fileName
        chosenCompilers.javascriptExtensions = comp.extensions
        @program.choose compilerPrettyNames.css, (i) =>
          logger.blue "\n  You chose #{compilerPrettyNames.css[i]}."
          logger.green "\n  And finally, choose your micro-templating language:\n"
          comp = (compilerInfo.css.filter (item) => item.prettyName is compilerPrettyNames.css[i])[0]
          chosenCompilers.css = comp.fileName
          chosenCompilers.cssExtensions = comp.extensions
          @program.choose compilerPrettyNames.template,(i) =>
            logger.blue "\n  You chose #{compilerPrettyNames.template[i]}."
            logger.green "\n  Creating and setting up your project... \n"
            comp = (compilerInfo.template.filter (item) => item.prettyName is compilerPrettyNames.template[i])[0]
            chosenCompilers.template = comp.fileName
            chosenCompilers.templateExtensions = comp.extensions
            @_create(name, opts, chosenCompilers)

  _create: (name, opts, chosenCompilers) =>
    skeletonPath = path.join __dirname, '..', 'skeleton'

    # if name provided, simply copy directory into directory by that name
    # if name not provided, copy all skeleton contents into current directory
    @currPath = if name?.length > 0
      @_copySkeletonToProvidedDirectory(skeletonPath, name)
    else
      @_copySkeletonToCurrentDirectory(skeletonPath)

    @_makeChosenCompilerChanges(chosenCompilers)

    @_postCopyCleanUp()

    if opts.noserver then @_usingDefaultServer() else @_usingExpress()

  _copySkeletonToProvidedDirectory: (skeletonPath, name) ->
    currPath = path.join path.resolve(''), name
    logger.info "Copying skeleton project into #{currPath}"
    wrench.copyDirSyncRecursive skeletonPath, currPath
    currPath

  _copySkeletonToCurrentDirectory: (skeletonPath) ->
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

  _makeChosenCompilerChanges: (chosenCompilers) ->
    # defaults
    unless chosenCompilers?
      chosenCompilers =
        javascript: 'coffee'
        javascriptExtensions: ['coffee']
        css: 'sass'
        cssExtensions: ["scss", "sass"]
        template: 'handlebars'
        templateExtensions: ["hbs", "handlebars"]

    @_updateConfigForChosenCompilers(chosenCompilers)

    @_copyCompilerSpecificExampleFiles(chosenCompilers)

  _updateConfigForChosenCompilers: (chosenCompilers) ->

    # return if all the defaults were chosen
    return if chosenCompilers.javascript is defaults.defaultJavascript and
      chosenCompilers.css is defaults.defaultCss and
      chosenCompilers.template is defaults.defaultTemplate

    configPath = path.join @currPath, "mimosa-config.coffee"
    config = fs.readFileSync configPath, "ascii"
    config = config.replace "# compilers:", "compilers:"

    unless chosenCompilers.javascript is defaults.defaultJavascript
      config = config.replace "# javascript:", "javascript:"
      config = config.replace '# compileWith: "coffee"', 'compileWith: ' + JSON.stringify(chosenCompilers.javascript)
      unless chosenCompilers.javascript is "none"
        config = config.replace '# extensions: ["coffee"]', 'extensions:' + JSON.stringify(chosenCompilers.javascriptExtensions)

    unless chosenCompilers.css is defaults.defaultCss
      config = config.replace "# css:", "css:"
      config = config.replace '# compileWith: "sass"', 'compileWith: ' + JSON.stringify(chosenCompilers.css)
      unless chosenCompilers.css is "none"
        config = config.replace '# extensions: ["scss", "sass"]', 'extensions:' + JSON.stringify(chosenCompilers.cssExtensions)

    unless chosenCompilers.template is defaults.defaultTemplate
      config = config.replace "# template:", "template:"
      config = config.replace '# compileWith: "handlebars"', 'compileWith: ' + JSON.stringify(chosenCompilers.template)
      unless chosenCompilers.template is "none"
        config = config.replace '# extensions: ["hbs", "handlebars"]', 'extensions:' + JSON.stringify(chosenCompilers.templateExtensions)

    fs.writeFileSync configPath, config

    logger.success "Config changed to use selected compilers and to watch default extensions for those compilers."
    logger.success "You may want to check that the extensions Mimosa will watch match those you intend to use."

  _copyCompilerSpecificExampleFiles: (chosenCompilers) ->
    compExts = if chosenCompilers.javascript is "none" then ["js"]   else chosenCompilers.javascriptExtensions
    cssExts =  if chosenCompilers.css        is "none" then ["css"]  else chosenCompilers.cssExtensions
    tempExts = if chosenCompilers.template   is "none" then ["html"] else chosenCompilers.templateExtensions
    safePaths = [compExts, cssExts, tempExts].flatten().map (path) -> "\\.#{path}$"
    safePaths.push path.join("javascripts", "vendor")

    assetsPath = path.join @currPath,  'assets'
    allItems = wrench.readdirSyncRecursive(assetsPath)
    files = allItems.filter (i) -> fs.statSync(path.join(assetsPath, i)).isFile()

    for file in files
      filePath = path.join(assetsPath, file)
      isSafe = safePaths.some (path) -> file.match(path)

      # clear out the bad views
      if isSafe
        if filePath.has('example-view-')
          if tempExts.none((ext) -> filePath.has("-#{ext}."))
            isSafe = false
          else
            templateView = filePath

        isSafe = false if filePath.has('handlebars-helpers') and
          tempExts.none((ext) -> ext is "hbs")

      fs.unlink filePath unless isSafe

    # alter template view name and insert css framework
    if templateView?
      data = fs.readFileSync templateView, "ascii"
      fs.unlink templateView
      cssFramework = if chosenCompilers.css is "none" then "pure CSS" else chosenCompilers.css
      data = data.replace "CSSHERE", cssFramework
      templateView = templateView.replace /-\w+\./, "."
      fs.writeFile templateView, data

  _postCopyCleanUp: =>
    glob "#{@currPath}/**/.gitkeep", (err, files) ->
      fs.unlinkSync(file) for file in files

    # for some reason I can't quite figure out
    # won't copy over a public directory, so hack it out here
    newPublicPath = path.join @currPath, 'public'
    oldPublicPath = path.join @currPath, 'publicc'
    fs.renameSync oldPublicPath, newPublicPath

  # remove express files/directories and update config to point to default server
  _usingDefaultServer: ->
    fs.unlinkSync path.join(@currPath, "server.coffee")
    fs.unlinkSync path.join(@currPath, "package.json")
    wrench.rmdirSyncRecursive path.join(@currPath, "views")
    wrench.rmdirSyncRecursive path.join(@currPath, "routes")

    logger.info "Altering configuration to not use express"
    configPath = path.join @currPath, "mimosa-config.coffee"
    fs.readFile configPath, "ascii", (err, data) =>
      data = data.replace "# server:", "server:"
      data = data.replace "# useDefaultServer: false", "useDefaultServer: true"
      fs.writeFile configPath, data, @_done

  _usingExpress: ->
    logger.info "Installing node modules "
    currentDir = process.cwd()
    process.chdir @currPath
    exec "npm install", (err, sout, serr) =>
      process.chdir currentDir
      @_done()

  _done: ->
    logger.success "New project creation complete!"
    logger.success "Execute 'mimosa watch --server' from inside your project to monitor the file system. then start coding!"
    process.stdin.destroy()

  printHelp: ->
    logger.green('  The new command will create a directory using the name provided, and place a project skeleton inside of')
    logger.green('  it.  That project skeleton will by default include an basic Express app, with sample routes')
    logger.green('  and views.  It will also include some sample assets (CoffeeScript, SASS, Handlebars) to get you started. ')
    logger.blue( '\n    $ mimosa new [nameOfProject]\n')
    logger.green('  If you wish to copy the project skeleton into your current directory, leave off the name.')
    logger.blue( '\n    $ mimosa new\n')
    logger.green('  Pass a \'noserver flag\' to not include the basic Express app.  With this set up, if you choose to have')
    logger.green('  Mimosa serve up your assets, it will do so with an embedded Mimosa Express app, and not with one inside')
    logger.green('  your project')
    logger.blue( '\n    $ mimosa new [name] --noserver')
    logger.blue( '    $ mimosa new --noserver')
    logger.blue( '    $ mimosa new [name] -n')
    logger.blue( '    $ mimosa new -n\n')

module.exports = (program) ->
  command = new NewCommand(program)
  command.register()