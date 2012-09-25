module.exports = class JSCompiler

  lifecycleRegistration: (config, register) ->
    console.log "INSIDE JS COMPILER!!!!"
    register ['add','update','startup'], 'compile', [@extensions...], @compile