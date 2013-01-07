fs =   require 'fs'
path = require 'path'

windowsDrive = /^[A-Za-z]:\\/

exports.isArrayOfStrings = (errors, fld, obj) ->
  if Array.isArray(obj)
    for hFile in obj
      unless typeof hFile is 'string'
        errors.push("#{fld} must be an array of strings.")
        return false
  else
    errors.push("#{fld} must be an array.")
    return false

  true

exports.isArrayOfStringsIfExists = (errors, fld, obj) ->
  if obj?
    exports.isArrayOfStrings errors, fld, obj
  else
    false

exports.isObject = (errors, fld, obj) ->
  if typeof obj is "object" and not Array.isArray(obj)
    true
  else
    errors.push "#{fld} must be an object."
    false

exports.isObjectIfExists = (errors, fld, obj) ->
  if obj?
    exports.isObject errors, fld, obj
  else
    false

exports.doesPathExist = (errors, fld, pathh) ->
  unless fs.existsSync pathh
    errors.push "#{fld} [[ #{pathh} ]] cannot be found"
    return false

  if fs.statSync(pathh).isFile()
    errors.push "#{fld} [[ #{pathh} ]] cannot be found, expecting a directory and is a file"
    return false

  true

exports.determinePath = (pathh, relTo) ->
  return pathh if windowsDrive.test pathh
  return pathh if pathh.indexOf("/") is 0
  path.join relTo, pathh

exports.multiPathExists = (errors, fld, pathh, relTo) ->
  if typeof pathh is "string"
    pathh = exports.determinePath pathh, relTo
    exports.doesPathExist errors, fld, pathh
  else
    errors.push "#{fld} must be a string."
    false

exports.multiPathNeedNotExist = (errors, fld, pathh, relTo) ->
  if typeof pathh is "string"
    pathh = exports.determinePath pathh, relTo
    true
  else
    errors.push "#{fld} must be a string."
    false

exports.arrayOfMultiPathsNeedNotExist = (errors, fld, arrayOfPaths, relTo) ->
  if arrayOfPaths?
    if Array.isArray(arrayOfPaths)
      newPaths = []
      for pathh in arrayOfPaths
        if typeof pathh is "string"
          newPaths.push __determinePath pathh, relTo
        else
          errors.push "#{fld} must be an array of strings."
          break
      arrayOfPaths = newPaths
    else
      errors.push "#{fld} must be an array."
