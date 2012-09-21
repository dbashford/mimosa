path = require 'path'
fs =   require 'fs'

jsp = require("uglify-js").parser
pro = require("uglify-js").uglify
clean  = require 'clean-css'

logger = require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaMinifyModule

  lifecycleRegistration: (config) ->

    lifecycle = []

    if config.min
      @exclude = config.minify.exclude

      lifecycle.push
        types:['add','update','startup']
        step:'afterCompile'
        callback: @_minifyJS
        extensions:[config.extensions.javascript...]

    if config.optimize or config.min

      lifecycle.push
        types:['add','update','startup']
        step:'afterCompile'
        callback: @_minifyCSS
        extensions:[config.extensions.css...]

    lifecycle

  _minifyJS: (config, options, next) ->

    inputFile = options.inputFile
    source = options.fileContent

    excluded = @exclude?.some (path) -> fileName.match(path)

    if excluded
      logger.debug "Not going to minify [[ #{fileName} ]], it has been excluded."
    else
      logger.debug "Running minification on [[ #{fileName} ]]"
      options.fileContent = @performJSMinify(source)

    next()

  _minifyCSS: (config, options, next) ->
    console.log "Cleaning/optimizing CSS [[ #{options.destinationFile} ]]"
    logger.debug "Cleaning/optimizing CSS [[ #{options.destinationFile} ]]"
    options.fileContent = clean.process options.fileContent
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