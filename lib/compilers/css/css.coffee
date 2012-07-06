SingleFileCompiler = require '../single-file'

module.exports = class AbstractCSSCompiler extends SingleFileCompiler

  outExtension: 'css'

  constructor: (config) ->
    super(config, config.compilers.css)
