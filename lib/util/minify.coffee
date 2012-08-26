jsp = require("uglify-js").parser
pro = require("uglify-js").uglify

logger = require './logger'

class Uglifier

  setExclude: (@exclude) ->
    @

  minify: (fileName, source) ->

    excluded = @exclude?.some (path) -> fileName.match(path)

    if excluded
      logger.debug "Not going to minify [[ #{fileName} ]], it has been excluded."
    else
      logger.debug "Running minification on [[ #{fileName} ]]"
      try
        ast = jsp.parse source
        ast = pro.ast_mangle ast, {except:['require','requirejs','define']}
        ast = pro.ast_squeeze ast
        source = pro.gen_code ast
      catch err
        logger.warn "Minification failed on [[ #{fileName} ]], writing unminified source\n#{err}"

    source

module.exports = new Uglifier
