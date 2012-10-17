path = require 'path'
fs =   require 'fs'

wrench = require 'wrench'
logger = require 'mimosa-logger'
_      = require 'lodash'

class MimosaDefaults

  fatalErrors: 0

  moduleDefaults:
    watch:
      sourceDir: "assets"
      compiledDir: "public"
      javascriptDir: "javascripts"
      ignored: [".sass-cache"]
      throttle: 0
    compilers:
      extensionOverrides: {}
    template:
      outputFileName: "templates"
      helperFiles:["app/template/handlebars-helpers"]
    copy:
      extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml"]
    server:
      useDefaultServer: false
      useReload: true
      path: 'server.coffee'
      port: 3000
      base: ''
      views:
        compileWith: 'jade'
        extension: 'jade'
        path: 'views'
    require:
      verify:
        enabled: true
      optimize :
        inferConfig:true
        overrides:{}
    growl:
      onStartup: false
      onSuccess:
        javascript: true
        css: true
        template: true
        copy: true
    minify:
      exclude:["\.min\."]
    lint:
      compiled:
        javascript:true
        css:true
      copied:
        javascript: true
        css: true
      vendor:
        javascript: false
        css: false
      rules:
        javascript: {}
        css: {}

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

  _extend: (obj, props) ->
    Object.keys(props).forEach (k) =>
      val = props[k]
      if val? and _.isObject(val)
        @_extend obj[k], val
      else
        obj[k] = val
    obj

  _applyDefaults: (config) ->
    config = @_extend @moduleDefaults, config

    config.extensions = {javascript: ['js'], css: ['css'], template: [], copy: []}
    config.watch.sourceDir =             path.join @root, config.watch.sourceDir
    config.watch.compiledDir =           path.join @root, config.watch.compiledDir
    config.watch.compiledJavascriptDir = path.join config.watch.compiledDir, config.watch.javascriptDir

    # TODO, validate extensionOverride compiler names

    config.server.path = path.join @root, config.server.path
    if config.server.views.compileWith is "html"
      config.server.views.compileWith = "ejs"
      config.server.views.html = true
    config.server.views.path =         path.join @root, config.server.views.path

    # need to set some requirejs stuf
    if config.isOptimize and config.isMinify
      logger.info "Optimize and minify both selected, setting r.js optimize property to 'none'"
      config.require.optimize.overrides.optimize = "none"

    # helpful shortcuts
    config.requireRegister = config.require.verify.enabled or config.isOptimize

    logger.debug "Full mimosa config:\n#{JSON.stringify(config, null, 2)}"

    config

  _validateSettings: (config) ->
    @_testPathExists(config.watch.sourceDir, "watch.sourceDir", true)
    unless config.isVirgin
      if !fs.existsSync(config.watch.compiledDir) and !config.isForceClean
        logger.info "Did not find compiled directory [[ #{config.watch.compiledDir} ]], so making it for you"
        wrench.mkdirSyncRecursive config.watch.compiledDir, 0o0777

      @_testPathExists(config.server.path, "server.path", false) if config.isServer and not config.server.useDefaultServer

    # TODO, compilers: overrides paths

    jsDir = path.join(config.watch.sourceDir, config.watch.javascriptDir)
    @_testPathExists(jsDir,"watch.javascriptDir", true) unless config.isVirgin

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