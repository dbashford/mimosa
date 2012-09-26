module.exports = class JSCompiler

  lifecycleRegistration: (config, register) ->
    register ['add','update','startup'], 'compile', [@extensions...], @compile