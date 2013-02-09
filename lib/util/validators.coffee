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

exports.isArrayOfObjects = (errors, fld, obj) ->
  if Array.isArray(obj)
    for hFile in obj
      if typeof hFile is "object" and not Array.isArray(hFile)
        # do nothing
      else
        errors.push("#{fld} must be an array of objects.")
        return false
  else
    errors.push("#{fld} must be an array.")
    return false

  true

exports.isString = (errors, fld, obj) ->
  if typeof obj is "string"
    true
  else
    errors.push "#{fld} must be a string."
    false

exports.isObject = (errors, fld, obj) ->
  if typeof obj is "object" and not Array.isArray(obj)
    true
  else
    errors.push "#{fld} must be an object."
    false

exports.isArray = (errors, fld, obj) ->
  if Array.isArray(obj)
    true
  else
    errors.push "#{fld} must be an array."
    false

exports.isNumber = (errors, fld, obj) ->
  if typeof obj is "number"
    true
  else
    errors.push "#{fld} must be a number."
    false

exports.ifExistsIsArrayOfStrings = (errors, fld, obj) ->
  if obj?
    exports.isArrayOfStrings errors, fld, obj
  else
    false

exports.ifExistsIsArrayOfObjects = (errors, fld, obj) ->
  if obj?
    exports.isArrayOfObjects errors, fld, obj
  else
    false

exports.ifExistsIsNumber = (errors, fld, obj) ->
  if obj?
    exports.isNumber errors, fld, obj
  else
    false

exports.ifExistsIsString = (errors, fld, obj) ->
  if obj?
    exports.isString errors, fld, obj
  else
    false

exports.ifExistsIsArray = (errors, fld, obj) ->
  if obj?
    exports.isArray errors, fld, obj
  else
    false

exports.ifExistsIsObject = (errors, fld, obj) ->
  if obj?
    exports.isObject errors, fld, obj
  else
    false

exports.ifExistsIsBoolean = (errors, fld, obj) ->
  if obj?
    if typeof obj is "boolean"
      true
    else
      errors.push "#{fld} must be a boolean."
      false
  else
    false

exports.stringMustExist = (errors, fld, obj) ->
  if obj?
    if typeof obj isnt "string"
      errors.push "#{fld} must be a string."
    else
     true
  else
    errors.push "#{fld} must be present."
    false

exports.booleanMustExist = (errors, fld, obj) ->
  if obj?
    if typeof obj isnt "boolean"
      errors.push "#{fld} must be a string."
      false
    else
      true
  else
    errors.push "#{fld} must be present."
    false

exports.isArrayOfStringsMustExist = (errors, fld, obj) ->
  if obj?
    if Array.isArray(obj)
      for s in obj
        unless typeof s is "string"
          errors.push "#{fld} must be an array of strings."
          return false
    else
      errors.push "#{fld} configuration must be an array."
      return false
  else
    errors.push "#{fld} must be present."
    return false

  true

exports.multiPathMustExist = (errors, fld, pathh, relTo) ->
  if typeof pathh is "string"
    pathh = exports.determinePath pathh, relTo
    pathExists = exports.doesPathExist errors, fld, pathh
    if pathExists then pathh else false
  else
    errors.push "#{fld} must be a string."
    false

exports.multiPathNeedNotExist = (errors, fld, pathh, relTo) ->
  if typeof pathh is "string"
    exports.determinePath pathh, relTo
  else
    errors.push "#{fld} must be a string."
    false

exports.ifExistsArrayOfMultiPaths = (errors, fld, arrayOfPaths, relTo) ->
  if arrayOfPaths?
    if Array.isArray(arrayOfPaths)
      newPaths = []
      for pathh in arrayOfPaths
        if typeof pathh is "string"
          newPaths.push exports.determinePath pathh, relTo
        else
          errors.push "#{fld} must be an array of strings."
          return false
      arrayOfPaths.length = 0
      arrayOfPaths.push newPaths...
    else
      errors.push "#{fld} must be an array."
      return false

  true

exports.ifExistsFileExcludeWithRegexAndString = (errors, fld, obj, relTo) ->
  if obj.exclude?
    if Array.isArray(obj.exclude)
      regexes = []
      newExclude = []
      for exclude in obj.exclude
        if typeof exclude is "string"
          newExclude.push exports.determinePath exclude, relTo
        else if exclude instanceof RegExp
          regexes.push exclude.source
        else
          errors.push "#{fld} must be an array of strings and/or regexes."
          return false

      if regexes.length > 0
        obj.excludeRegex = new RegExp regexes.join("|"), "i"

      obj.exclude = newExclude
    else
      errors.push "#{fld} must be an array"
      return false

  true

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