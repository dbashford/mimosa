path = require 'path'
fs =   require 'fs'

logger =   require '../../util/logger'

defaultJavascript = "coffee"
defaultCss = "sass"
defaultTemplate = "handlebars"

class MimosaDefaults

  fatalErrors: 0

  applyAndValidateDefaults: (config, configPath, callback) =>
    @root = path.dirname(configPath)
    config = @_applyDefaults(config)
    @_validateSettings(config)
    err = if @fatalErrors is 0
      logger.debug "No mimosa config errors"
      null
    else
      @fatalErrors
    callback(err, config)

  _applyDefaults: (config) ->
    newConfig = {}

    newConfig.virgin =   config.virgin
    newConfig.isServer = config.isServer
    newConfig.optimize = config.optimize
    newConfig.min =      config.min

    newConfig.watch =             config.watch ?= {}
    newConfig.watch.sourceDir =   path.join(@root, config.watch.sourceDir   ? "assets")
    newConfig.watch.compiledDir = path.join(@root, config.watch.compiledDir ? "public")
    newConfig.watch.ignored =     config.watch.ignored ?= [".sass-cache"]
    newConfig.watch.throttle =    config.watch.throttle ?= 0

    comp = newConfig.compilers = config.compilers ?= {}
    js = comp.javascript = config.compilers.javascript ?= {}
    js.directory =         config.compilers.javascript.directory         ?= "javascripts"
    js.compileWith =       config.compilers.javascript.compileWith       ?= defaultJavascript
    js.extensions = if js.compileWith is "none"
       ['js']
    else
      config.compilers.javascript.extensions ? ["coffee"]

    template = comp.template = config.compilers.template                 ?= {}
    template.compileWith =     config.compilers.template.compileWith     ?= defaultTemplate
    template.extensions =      config.compilers.template.extensions      ?= ["hbs", "handlebars"]
    template.outputFileName =  config.compilers.template.outputFileName  ?= "javascripts/templates"

    if template.compileWith is "handlebars"
      template.helperFile = []
      helperFiles = config.compilers.template.helperFiles ?= ["javascripts/app/template/handlebars-helpers"]
      for helperFile in helperFiles
        template.helperFile.push path.join(@root, helperFile)

    css = comp.css =      config.compilers.css                 ?= {}
    css.compileWith =     config.compilers.css.compileWith     ?= defaultCss
    css.extensions = if css.compileWith is "none"
      ['css']
    else
      config.compilers.css.extensions ? ["scss", "sass"]

    copy = newConfig.copy = config.copy                        ?= {}
    copy.extensions =       config.copy.extensions             ?= ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]

    requirejs = newConfig.require = config.require             ?= {}

    unless config.virgin
      server = newConfig.server = config.server                  ?= {}
      server.useDefaultServer =   config.server.useDefaultServer ?= false
      server.port =               config.server.port             ?= 3000
      server.base =               config.server.base             ?= '/app'
      server.useReload =          config.server.useReload        ?= true
      server.path =               config.server.path             ?= 'server.coffee'

      server.path = path.join(@root, server.path)

      requirejs.optimize = newConfig.require.optimize = config.require.optimize     ?= {}
      requirejs.optimize.inferConfig = config.require.optimize.inferConfig ?= true
      requirejs.optimize.overrides = config.require.optimize.overrides ?= {}

    requirejs.verify = newConfig.require.verify = config.require.verify ?= {}
    requirejs.verify.enabled = config.require.verify.enabled            ?= true

    minify = newConfig.minify =       config.minify             ?= {}
    minify.exclude = config.minify.exclude                ?= ["\.min\."]

    # need to set some requirejs stuf
    if config.optimize and config.min
      logger.info "Optimize and minify both selected, setting r.js optimize property to 'none'"
      requirejs.optimize.overrides.optimize = "none"

    growl = newConfig.growl =       config.growl                ?= {}
    growl.onStartup =               config.growl.onStartup            ?= false
    growl.onSuccess =               config.growl.onSuccess            ?= {}
    growl.onSuccess.javascript =    config.growl.onSuccess.javascript ?= true
    growl.onSuccess.css =           config.growl.onSuccess.css        ?= true
    growl.onSuccess.template =      config.growl.onSuccess.template   ?= true
    growl.onSuccess.copy =          config.growl.onSuccess.copy       ?= true

    lint = newConfig.lint =    config.lint                     ?= {}
    lint.compiled =            config.lint.compiled            ?= {}
    lint.compiled.coffee =     config.lint.compiled.coffee     ?= true
    lint.compiled.javascript = config.lint.compiled.javascript ?= true
    lint.compiled.css =        config.lint.compiled.css        ?= true

    lint.copied =              config.lint.copied              ?= {}
    lint.copied.javascript =   config.lint.copied.javascript   ?= true
    lint.copied.css =          config.lint.copied.css          ?= true

    lint.vendor =              config.lint.vendor              ?= {}
    lint.vendor.javascript =   config.lint.vendor.javascript   ?= false
    lint.vendor.css =          config.lint.vendor.css          ?= false

    lint.rules =               config.lint.rules               ?= {}
    lint.rules.coffee =        config.lint.rules.coffee        ?= {}
    lint.rules.javascript =    config.lint.rules.javascript    ?= {}
    lint.rules.css =           config.lint.rules.css           ?= {}

    logger.debug "Full mimosa config:\n#{JSON.stringify(newConfig, null, 2)}"

    newConfig

  _validateSettings: (config) ->
    @_testPathExists(config.watch.sourceDir, "watch.sourceDir", true)
    unless config.virgin
      @_testPathExists(config.watch.compiledDir, "watch.compiledDir", true)
      @_testPathExists(config.server.path, "server.path", false) if config.isServer and not config.server.useDefaultServer

    comp = config.compilers
    templatePath = path.join(__dirname, '..', '..', 'compilers/template',  "#{comp.template.compileWith}-compiler.coffee")
    jsPath = path.join(      __dirname, '..', '..', 'compilers/javascript', "#{comp.javascript.compileWith}-compiler.coffee")
    cssPath = path.join(     __dirname, '..', '..', 'compilers/css',        "#{comp.css.compileWith}-compiler.coffee")

    @_testPathExists(templatePath, "compilers.template.compileWith", false) unless comp.template.compileWith is "none"
    @_testPathExists(cssPath,      "compilers.css.compileWith", false)      unless comp.css.compileWith is "none"
    unless comp.javascript.compileWith is "none"
      @_testPathExists(jsPath, "compilers.javascript.compileWith", false)
      jsDir = path.join(config.watch.sourceDir, comp.javascript.directory)
      @_testPathExists(jsDir,"compilers.javascript.directory", true) unless config.virgin

  _testPathExists: (filePath, name, isDirectory) ->
    unless fs.existsSync filePath
      logger.fatal "#{name} (#{filePath}) cannot be found"
      return @fatalErrors++

    stats = fs.statSync filePath
    if (isDirectory and stats.isFile())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a directory and is a file"
      return @fatalErrors++

    if (!isDirectory and stats.isDirectory())
      logger.fatal "#{name} (#{filePath}) cannot be found, expecting a file and is a directory"
      return @fatalErrors++

module.exports = {
  applyAndValidateDefaults: (new MimosaDefaults()).applyAndValidateDefaults
}