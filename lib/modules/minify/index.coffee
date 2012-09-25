path = require 'path'
fs =   require 'fs'

jsp = require("uglify-js").parser
pro = require("uglify-js").uglify
clean  = require 'clean-css'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaMinifyModule

  lifecycleRegistration: (config, register) ->
    if config.min
      @exclude = config.minify.exclude
      register ['add','update','startup'], 'afterCompile', [config.extensions.javascript...], @_minifyJS

    if config.optimize or config.min
      register ['add','update','startup'], 'afterCompile', [config.extensions.css...],        @_minifyCSS

  _minifyJS: (config, options, next) ->

    inputFile = options.inputFile
    source = options.output

    excluded = @exclude?.some (path) -> fileName.match(path)

    if excluded
      logger.debug "Not going to minify [[ #{fileName} ]], it has been excluded."
    else
      logger.debug "Running minification on [[ #{fileName} ]]"
      options.output = @performJSMinify(source)

    next()

  _minifyCSS: (config, options, next) ->
    console.log "Cleaning/optimizing CSS [[ #{options.destinationFile} ]]"
    logger.debug "Cleaning/optimizing CSS [[ #{options.destinationFile} ]]"
    options.output = clean.process options.output
    next()

  performJSMinify: (source) ->
    try
      ast = jsp.parse source
      ast = pro.ast_mangle ast, {except:['require','requirejs','define']}
      ast = pro.ast_squeeze ast
      pro.gen_code ast
    catch err
      logger.warn "Minification failed on [[ #{fileName} ]], writing unminified source\n#{err}"


module.exports = new MimosaMinifyModule()