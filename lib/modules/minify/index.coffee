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
      register ['add','update','buildFile'],      'afterCompile', @_minifyJS,  [e.javascript...]
      register ['add','update','buildExtension'], 'beforeWrite',  @_minifyJS,  [e.template...]

    if config.optimize or config.min
      register ['add','update','buildFile'],      'afterCompile', @_minifyCSS, [e.css...]

  _minifyJS: (config, options, next) =>
    return next() unless options.files?.length > 0

    i = 0
    options.files.forEach (file) =>
      fileName = file.outputFileName
      text = file.outputFileText
      if fileName and text
        excluded = @exclude?.some (path) -> fileName.match(path)

        if excluded
          logger.debug "Not going to minify [[ #{fileName} ]], it has been excluded."
        else
          logger.debug "Running minification on [[ #{fileName} ]]"
          file.outputFileText = @performJSMinify(text, fileName)

      next() if ++i is options.files.length

  _minifyCSS: (config, options, next) ->
    return next() unless options.files?.length > 0

    logger.debug "Cleaning/optimizing CSS [[ #{options.files} ]]"
    i = 0
    options.files.forEach (file) ->
      file.outputFileText = clean.process file.outputFileText
      next() if ++i is options.files.length

  performJSMinify: (source, fileName) ->
    try
      text = jsp.parse source
      text = pro.ast_mangle text, {except:['require','requirejs','define']}
      text = pro.ast_squeeze text
      pro.gen_code text
    catch err
      logger.warn "Minification failed on [[ #{fileName} ]], writing unminified source\n#{err}"

module.exports = new MimosaMinifyModule()