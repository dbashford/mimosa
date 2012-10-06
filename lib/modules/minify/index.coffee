path = require 'path'
fs =   require 'fs'

jsp =   require("uglify-js").parser
pro =   require("uglify-js").uglify
clean  = require 'clean-css'

logger =    require '../../util/logger'
fileUtils = require '../../util/file'

class MimosaMinifyModule

  lifecycleRegistration: (config, register) ->
    e = config.extensions

    if config.min
      @exclude = config.minify.exclude
      register ['add','update','startupFile'],      'afterCompile', @_minifyJS, [e.javascript...]
      register ['add','update','startupExtension'], 'beforeWrite',  @_minifyJS, [e.template...]

    if config.optimize or config.min
      register ['add','update','startupFile'], 'afterCompile', @_minifyCSS, [e.css...]

  _minifyJS: (config, options, next) ->
    i = 0
    options.files.forEach (file) =>
      inputFile = file.inputFileName
      excluded = @exclude?.some (path) -> inputFile.match(path)

      if excluded
        logger.debug "Not going to minify [[ #{inputFile} ]], it has been excluded."
      else
        logger.debug "Running minification on [[ #{inputFile} ]]"
        file.outputFileText = @performJSMinify(file.outputFileText)

      next() if ++i is options.files.length

  _minifyCSS: (config, options, next) ->
    logger.debug "Cleaning/optimizing CSS [[ #{options.files} ]]"
    i = 0
    options.files.forEach (file) ->
      file.outputFileText = clean.process options.outputFileText
      next() if ++i is options.files.length

  performJSMinify: (source) ->
    try
      ast = jsp.parse source
      ast = pro.ast_mangle ast, {except:['require','requirejs','define']}
      ast = pro.ast_squeeze ast
      pro.gen_code ast
    catch err
      logger.warn "Minification failed on [[ #{fileName} ]], writing unminified source\n#{err}"

module.exports = new MimosaMinifyModule()