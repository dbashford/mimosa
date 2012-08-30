path =   require 'path'
{exec} = require 'child_process'
fs =     require 'fs'

wrench = require 'wrench'
_ =      require 'lodash'

fileUtils = require '../util/file'
logger =   require '../util/logger'
util =     require './util'
defaults = require './util/defaults'

class NewCommand

  servers: [
      {name:"express", prettyName:"(*) Express - http://expressjs.com/", isDefault:true}
      {name:"none", prettyName:"None - Mimosa will serve your application for you"}
    ]

  constructor: (@program) ->

  register: =>
    @program
      .command('new [name]')
      .description("create a skeleton matching Mimosa's defaults, which includes a basic Express setup")
      .option("-d, --defaults",  "bypass prompts and go with Mimosa defaults (CoffeeScript, SASS, Handlebars)")
      .option("-D, --debug", "run in debug mode")
      .action(@new)
      .on '--help', @printHelp

  new: (name, opts) =>
    if opts.debug then logger.setDebug()

    logger.debug "Project name: #{name}"

    # give them something to read while we check to see if SASS is installed
    unless opts.defaults
      logger.green "\n  Mimosa will guide you through project creation. You will be prompted to pick the JavaScript"
      logger.green "  meta-language, CSS meta-language, and micro-templating library you would like to use. For more"
      logger.green "  about those choices, see http://mimosajs.com/compilers.html.  You will also be prompted to pick"
      logger.green "  the server you would like to use. If you pick no server, Mimosa will serve your assets for you.\n"
      logger.green "  For all of the technologies, if your favorite is not an option, you can add a GitHub issue"
      logger.green "  and we'll look into adding it. (https://github.com/dbashford/mimosa/issues)\n"

    util.projectPossibilities (compilers) =>
      if opts.defaults
        @_createWithDefaults(compilers, name)
      else
        @_prompting(compilers, name)

  _prompting: (compilers, name) =>
    logger.debug "Compilers :\n#{JSON.stringify(compilers, null, 2)}"

    chosen = {}

    logger.green "  If you are unsure which options to pick, the ones with asterisks are Mimosa favorites. Feel free"
    logger.green "  to hit the web to research your selections, Mimosa will be here when you get back."

    logger.green "\n  To start, please choose your JavaScript meta-language: \n"
    @program.choose _.pluck(compilers.javascript, 'prettyName'), (i) =>
      logger.blue "\n  You chose #{compilers.javascript[i].prettyName}."
      chosen.javascript = compilers.javascript[i]
      logger.green "\n  Now choose your CSS meta-language:\n"
      @program.choose _.pluck(compilers.css, 'prettyName'), (i) =>
        logger.blue "\n  You chose #{compilers.css[i].prettyName}."
        chosen.css = compilers.css[i]
        logger.green "\n  And choose your micro-templating language:\n"
        @program.choose _.pluck(compilers.template, 'prettyName'),(i) =>
          logger.blue "\n  You chose #{compilers.template[i].prettyName}."
          chosen.template = compilers.template[i]
          logger.green "\n  And finally choose your server technology:\n"
          @program.choose _.pluck(@servers, 'prettyName'),(i) =>
            logger.blue "\n  You chose #{@servers[i].prettyName}."
            chosen.server = @servers[i]
            logger.green "\n  Creating and setting up your project... \n"
            @_create(name, chosen)

  _createWithDefaults: (compilers, name) =>
    chosen = {}
    chosen.css =        (compilers.css.filter        (item) -> item.isDefault)[0]
    chosen.javascript = (compilers.javascript.filter (item) -> item.isDefault)[0]
    chosen.template =   (compilers.template.filter   (item) -> item.isDefault)[0]
    chosen.server =     (@servers.filter             (item) -> item.isDefault)[0]
    @_create(name, chosen)

  _create: (name, chosen) =>
    skeletonPath = path.join __dirname, '..', 'skeleton'

    # if name provided, simply copy directory into directory by that name
    # if name not provided, copy all skeleton contents into current directory
    @currPath = if name?.length > 0
      @_copySkeletonToProvidedDirectory(skeletonPath, name)
    else
      @_copySkeletonToCurrentDirectory(skeletonPath)

    @_makeChosenCompilerChanges(chosen)

    @_postCopyCleanUp()

    if chosen.server.name is "none"
      @_usingDefaultServer()
    else
      @_usingOwnServer(name, chosen)

  _copySkeletonToProvidedDirectory: (skeletonPath, name) ->
    currPath = path.join path.resolve(''), name
    logger.info "Copying skeleton project into #{currPath}"
    wrench.copyDirSyncRecursive skeletonPath, currPath
    currPath

  _copySkeletonToCurrentDirectory: (skeletonPath) ->
    logger.info "A project name was not provided, copying skeleton into the current directory"
    currPath = path.join path.resolve(''), path.sep
    @_moveDirectoryContents(skeletonPath)
    currPath

  _moveDirectoryContents: (sourcePath, outPath) ->
    contents = wrench.readdirSyncRecursive(sourcePath)
    for item in contents
      fullSourcePath = path.join sourcePath, item
      fileStats = fs.statSync fullSourcePath
      fullOutPath = path.join(outPath, item)
      if fileStats.isDirectory()
        logger.debug "Copying directory: [[ #{fullOutPath} ]]"
        wrench.mkdirSyncRecursive fullOutPath, 0o0777
      if fileStats.isFile()
        logger.debug "Copying file: [[ #{fullOutPath} ]]"
        fileContents = fs.readFileSync fullSourcePath
        fs.writeFileSync fullOutPath, fileContents

  _makeChosenCompilerChanges: (chosenCompilers) ->
    logger.debug "Chosen compilers:\n#{JSON.stringify(chosenCompilers, null, 2)}"

    @_updateConfigForChosenCompilers(chosenCompilers)
    @_copyCompilerSpecificExampleFiles(chosenCompilers)

  _updateConfigForChosenCompilers: (comps) ->

    # return if all the defaults were chosen
    return if comps.javascript.isDefault and comps.css.isDefault and comps.template.isDefault

    configPath = path.join @currPath, "mimosa-config.coffee"
    config = fs.readFileSync configPath, "ascii"
    config = config.replace "# compilers:", "compilers:"

    unless comps.javascript.isDefault
      config = config.replace "# javascript:", "javascript:"
      config = config.replace '# compileWith: "coffee"', 'compileWith: ' + JSON.stringify(comps.javascript.fileName)
      config = config.replace "# server:", "server:"
      config = config.replace "# path: 'server.coffee'", "path: 'server.#{comps.javascript.defaultExtensions[0]}'"
      unless comps.javascript.fileName is "none"
        config = config.replace '# extensions: ["coffee"]', 'extensions:' + JSON.stringify(comps.javascript.defaultExtensions)

    unless comps.css.isDefault
      config = config.replace "# css:", "css:"
      config = config.replace '# compileWith: "sass"', 'compileWith: ' + JSON.stringify(comps.css.fileName)
      unless comps.css.fileName is "none"
        config = config.replace '# extensions: ["scss", "sass"]', 'extensions:' + JSON.stringify(comps.css.defaultExtensions)

    unless comps.template.isDefault
      config = config.replace "# template:", "template:"
      config = config.replace '# compileWith: "handlebars"', 'compileWith: ' + JSON.stringify(comps.template.fileName)
      unless comps.template.fileName is "none"
        config = config.replace '# extensions: ["hbs", "handlebars"]', 'extensions:' + JSON.stringify(comps.template.defaultExtensions)

    fs.writeFileSync configPath, config

    logger.success "Config changed to use selected compilers and to watch default extensions for those compilers."
    logger.success "You may want to check that the extensions Mimosa will watch match those you intend to use."

  _copyCompilerSpecificExampleFiles: (comps) ->
    safePaths = _.flatten([comps.javascript.defaultExtensions, comps.css.defaultExtensions, comps.template.defaultExtensions]).map (path) ->
      "\\.#{path}$"
    safePaths.push "javascripts[/\\\\]vendor"

    assetsPath = path.join @currPath,  'assets'
    allItems = wrench.readdirSyncRecursive(assetsPath)
    files = allItems.filter (i) -> fs.statSync(path.join(assetsPath, i)).isFile()

    for file in files
      filePath = path.join(assetsPath, file)
      isSafe = safePaths.some (path) -> file.match(path)

      # clear out the bad views
      if isSafe
        if filePath.indexOf('example-view-') >= 0
          unless _.some(comps.template.defaultExtensions, (ext) -> filePath.indexOf("-#{ext}.") >= 0)
            isSafe = false
          else
            templateView = filePath

        isSafe = false if filePath.indexOf('handlebars-helpers') >= 0 and
          not _.some(comps.template.defaultExtensions, (ext) -> ext is "hbs")

      fs.unlink filePath unless isSafe

    serverPath = path.join @currPath,  'servers'
    allItems = wrench.readdirSyncRecursive(serverPath)
    files = allItems.filter (i) -> fs.statSync(path.join(serverPath, i)).isFile()
    for file in files
      filePath = path.join(serverPath, file)
      isSafe = safePaths.some (path) -> file.match(path)
      fs.unlink filePath unless isSafe

    # alter template view name and insert css framework
    if templateView?
      data = fs.readFileSync templateView, "ascii"
      fs.unlink templateView
      cssFramework = if comps.css.fileName is "none" then "pure CSS" else comps.css.fileName
      data = data.replace "CSSHERE", cssFramework
      templateView = templateView.replace /-\w+\./, "."
      fs.writeFile templateView, data

  _postCopyCleanUp: =>
    data = fs.readFileSync (path.join @currPath, '.npmignore'), 'ascii'
    logger.debug "Writing .gitignore"
    fs.writeFileSync path.join(@currPath, '.gitignore'), data, 'ascii'

    files = fileUtils.glob "#{@currPath}/**/.gitkeep", {dot:true}
    logger.debug "Removing #{files.length} .gitkeeps"
    fs.unlinkSync(file) for file in files

  # remove express files/directories and update config to point to default server
  _usingDefaultServer: ->
    logger.debug "Using default server, so removing server resources"
    fs.unlinkSync path.join(@currPath, "package.json")
    wrench.rmdirSyncRecursive path.join(@currPath, "views")
    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.debug "Altering configuration to not use server"
    configPath = path.join @currPath, "mimosa-config.coffee"
    fs.readFile configPath, "ascii", (err, data) =>
      data = data.replace "# server:", "server:"
      data = data.replace "# useDefaultServer: false", "useDefaultServer: true"
      fs.writeFile configPath, data, @_done

  _usingOwnServer: (name, chosen) ->
    # minor, kinda silly, but change name in package json to match project name
    if name?.length > 0
      logger.debug "Making package.json edits"
      jPath = path.join @currPath, "package.json"
      packageJson = require(jPath)
      packageJson.name = name
      unless chosen.javascript.fileName is "iced"
        logger.debug "removing iced coffee from package.json"
        delete packageJson.dependencies["iced-coffee-script"]
      fs.writeFileSync jPath, JSON.stringify(packageJson, null, 2)

    logger.debug "Moving server into place"
    @_moveDirectoryContents(path.join(@currPath, "servers", chosen.server.name), @currPath)
    wrench.rmdirSyncRecursive path.join(@currPath, "servers")

    logger.info "Installing node modules"
    currentDir = process.cwd()
    process.chdir @currPath
    exec "npm install", (err, sout, serr) =>
      logger.debug "Node module install err: #{err}"
      logger.debug "Node module install sout: #{sout}"
      logger.debug "Node module install serr: #{serr}"
      process.chdir currentDir
      @_done()

  _done: ->
    logger.success "New project creation complete!"
    logger.success "Execute 'mimosa watch --server' from inside your project to monitor the file system. then start coding!"
    process.stdin.destroy()

  printHelp: ->
    logger.green('  The new command will take you through a series of questions regarding what JavaScript meta-language, CSS')
    logger.green('  meta-language, micro-templating library, and server technology you would like to use to build your project')
    logger.green('  Once you have answered the questions, Mimosa will create a directory using the name you provided, and place')
    logger.green('  a project skeleton inside of it.  That project skeleton will by default include a basic application using')
    logger.green('  the technologies you selected')
    logger.blue( '\n    $ mimosa new [nameOfProject]\n')
    logger.green('  If you wish to copy the project skeleton into your current directory instead of into a new one leave off the')
    logger.green('  then leave off name.')
    logger.blue( '\n    $ mimosa new\n')
    logger.green('  If you are happy with the defaults (CoffeeScript, SASS, Handlebars, Express), you can bypass the prompts')
    logger.green('   by providing a \'defaults\' flag.')
    logger.blue( '\n    $ mimosa new [name] --defaults')
    logger.blue( '    $ mimosa new [name] -d\n')

module.exports = (program) ->
  command = new NewCommand(program)
  command.register()