module.exports = class JSCompiler

  lifecycleRegistration: (config, register) ->
    register ['add','update','startupFile'], 'compile', @compile, [@extensions...]