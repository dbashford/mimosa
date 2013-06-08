color  = require('ansi-color').set
logger = require 'logmimosa'

compilerCentral = require '../modules/compilers'

exports.projectPossibilities = (callback) ->
  compilers = compilerCentral.compilersByType()

  # just need to check SASS
  for comp in compilers.css
    # this won't work as is if a second compiler needs to shell out
    if comp.checkIfExists?
      comp.checkIfExists (exists) =>
        unless exists
          logger.debug "Compiler for file [[ #{comp.fileName} ]], is not installed/available"
          comp.prettyName = comp.prettyName + color(" (This is not installed and would need to be before use)", "yellow+bold")
        callback(compilers)
      break

exports.deepFreeze = (o) ->
  if o?
    Object.freeze(o)
    Object.getOwnPropertyNames(o).forEach (prop) =>
      if o.hasOwnProperty(prop) and o[prop] isnt null and
      (typeof o[prop] is "object" || typeof o[prop] is "function") and
      not Object.isFrozen(o[prop])
        exports.deepFreeze o[prop]
