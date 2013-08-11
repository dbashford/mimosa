logger = require 'logmimosa'

module.exports = class BaseCompiler

  determineCompilerLib: (mimosaConfig) =>
    if not @compilerLib and @libName
      if mimosaConfig.compilers.libs[@constructor.base]
        logger.debug "Using provided [[ #{@constructor.base} ]] compiler"
        @compilerLib = mimosaConfig.compilers.libs[@constructor.base]
      else
        logger.debug "Using Mimosa embedded [[ #{@constructor.base} ]] compiler"
        unless @libName is 'node-sass'
          @compilerLib = require @libName