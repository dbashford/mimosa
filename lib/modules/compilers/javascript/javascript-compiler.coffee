

module.exports = class JSCompiler

  lifecycleRegistration: ->

    lifecycle = []

    lifecycle.push
      types:['add','update','startup']
      step:'compile'
      callback: @compile
      extensions:[@extensions...]

    lifecycle
