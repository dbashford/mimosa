"use strict"

path = require 'path'
fs =   require 'fs'

_ =      require 'lodash'
logger = require 'logmimosa'
wrench = require 'wrench'

baseDirRegex = /([^[\/\\\\]*]*)$/

class MimosaCompilerModule

  all: []

  constructor: ->
    @all = wrench.readdirSyncRecursive(__dirname)
      .filter (f) ->
        (/-compiler.js$/).test(f) or (/copy.js$/).test(f)
      .map (f) ->
        file = path.join __dirname, f
        comp = require(file)
        comp.base = path.basename(file, ".js").replace('-compiler', '')
        if comp.base isnt "copy"
          comp.type = baseDirRegex.exec(path.dirname(file))[0]
        else
          comp.type = "copy"
        comp

  registration: (config, register) ->
    for compiler in @configuredCompilers.compilers
      compiler.registration(config, register) if compiler.registration?

    if config.template
      register ['buildExtension'], 'complete', @_testDifferentTemplateLibraries, config.extensions.template

  _testDifferentTemplateLibraries: (config, options, next) =>
    hasFiles = options.files?.length > 0
    return next() unless hasFiles
    return next() unless typeof config.template.outputFileName is "string"

    unless @templateLibrariesBeingUsed
      @templateLibrariesBeingUsed = 0

    if ++@templateLibrariesBeingUsed is 2
      logger.error "More than one template library is being used, but multiple template.outputFileName entries not found." +
        " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" +
        " template output for one of the libraries."

    next()

  _compilersWithoutCopy: ->
    @all.filter (comp) -> comp.base isnt "copy"

  compilersByType: ->
    compilersByType = {css:[], javascript:[], template:[]}
    for comp in @_compilersWithoutCopy()
      compilersByType[comp.type].push(comp)
    compilersByType

  setupCompilers: (config) ->
    allOverriddenExtensions = []
    for base, ext of config.compilers.extensionOverrides
      allOverriddenExtensions.push(ext...)

    logger.debug("All overridden extension [[ #{allOverriddenExtensions.join(', ')}]]")

    allCompilers = []
    extHash = {}

    compilers = @all.filter (comp) ->
      comp.base isnt "none"

    if config.template is null
      compilers = compilers.filter (comp) ->
        comp.type isnt "template"

    for Compiler in compilers
      extensions = if Compiler.base is "copy"
        config.copy.extensions
      else
        if config.compilers.extensionOverrides[Compiler.base] is null
          logger.debug "Not registering compiler [[ #{Compiler.base} ]], has been set to null in config."
          false
        else if config.compilers.extensionOverrides[Compiler.base]?
          config.compilers.extensionOverrides[Compiler.base]
        else
          # check and see if an overridden extension conflicts with an existing one
          _.difference Compiler.defaultExtensions, allOverriddenExtensions

      # compiler left without extensions, don't register

      #continue if extensions.length is 0
      if extensions
        compiler = new Compiler(config, extensions)
        allCompilers.push compiler
        extHash[ext] = compiler for ext in compiler.extensions
        config.extensions[Compiler.type].push(extensions...)

    for type, extensions of config.extensions
      config.extensions[type] = _.uniq(extensions)

    logger.debug("Compiler/Extension hash \n #{extHash}")

    @configuredCompilers = {compilerExtensionHash:extHash, compilers:allCompilers}

    @

  getCompilers: ->
    @configuredCompilers

  defaults: ->
    compilers:
      extensionOverrides: {}
    template:
      nameTransform:"fileName"
      amdWrap:true
      outputFileName: "templates"
      handlebars:
        helpers:["app/template/handlebars-helpers"]
        ember:
          enabled:false
          path:"vendor/ember"
    copy:
      extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md"]
    typescript:
      module:null
    coffeescript:
      sourceMap:true
      sourceMapExclude:[/\/spec\//]
      bare:true
    iced:
      bare:true
      runtime:'none'
    coco:
      bare:true
    stylus:
      use:['nib']
      import:['nib']
      define:{}

  placeholder: ->
    """
    \t

      # compilers:
        # extensionOverrides:       # A list of extension overrides, format is:
                                    # [compilerName]:[arrayOfExtensions], see
                                    # http://mimosajs.com/compilers.html for list of compiler names
          # coffee: ["coff"]        # This is an example override, this is not a default, must be
                                    # array of strings

      # coffeescript:                    # config settings for coffeescript
        # sourceMap:true                 # whether to generate source during "mimosa watch".
                                         # Source maps are not generated during "mimosa build"
                                         # regardless of setting.
        # sourceMapExclude: [/\/spec\//] # files to exclude from source map generation
        # bare:true                      # whether or not to include the top level wrapper around
                                         # each compiled coffeescript file. Defaults to not wrapping
                                         # as wrapping with define/require is assumed.

      # iced:                       # config settings for iced coffeescript
        # bare:true                 # whether or not to include the top level wrapper around each
                                    # compiled iced file. Defaults to not wrapping as wrapping with
                                    # define/require is assumed.
        # runtime:"none"            # No runtime boilerplate is included

      # typescript:                 # config settings for typescript
        # module: null              # how compiled tyepscript is wrapped, defaults to no wrapping,
                                    # can be "amd" or "commonjs"

      # coco:                    # config settings for coco
        # bare:true                      # whether or not to include the top level wrapper around
                                         # each compiled coffeescript file. Defaults to not wrapping
                                         # as wrapping with define/require is assumed.

      # stylus:                     # config settings for stylus
        # use:['nib']               # names of libraries to use, should match the npm name for
                                    # the desired libraries
        # import:['nib']            # Files to import for compilation
        # define: {}                # An object containing stylus variable defines

      # template:                         # overall template object can be set to null if no
                                          # templates being used
        # nameTransform: "fileName"       # means by which Mimosa creates the name for each
                                          # template, options: default "fileName" is name of file,
                                          # "filePath" is path of file after watch.javascriptDir
                                          # with the extension dropped, a supplied regex can be
                                          # used to remove any unwanted portions of the filePath,
                                          # and a provided function will be called with the
                                          # filePath as input
        # amdWrap: true                   # Whether or not to wrap the compiled template files in
                                          # an AMD wrapper for use with require.js
        # outputFileName: "templates"     # the file all templates are compiled into, is relative
                                          # to watch.javascriptDir.

        # outputFileName:                 # outputFileName Alternate Config 1
          # hogan:"hogans"                # Optionally outputFileName can be provided an object of
          # jade:"jades"                  # file extension to file name in the event you are using
                                          # multiple templating libraries. The file extension must
                                          # match one of the default compiler extensions or one of
                                          # the extensions configured for a compiler in the
                                          # compilers.extensionOverrides section above.

        # output: [{                      # output Alternate Config 2
        #   folders:[""]                  # Use output instead of outputFileName if you want
        #   outputFileName: ""            # to break up your templates into multiple files, for
        # }]                              # instance, if you have a two page app and want the
                                          # templates for each page to be built separately.
                                          # For each entry, provide an array of folders that
                                          # contain the templates to combine.  folders entries are
                                          # relative to watch.javascriptDir and must exist.
                                          # outputFileName works identically to outputFileName
                                          # above, including the alternate config, however, no
                                          # default file name is assumed. An output name must be
                                          # provided for each output entry, and the names
                                          # must be unique.

        # handlebars:                     # handlebars specific configuration
          # lib: null                     # an opportuntity to provide a specific version of the
                                          # handlebars compiler for template compilation. Use
                                          # node's require syntax to include a version that you
                                          # have included in your project.
          # helpers:["app/template/handlebars-helpers"]  # the paths from watch.javascriptDir to
                                          # the files containing handlebars helper/partial
                                          # registrations
          # ember:                        # Ember.js has its own Handlebars compilation needs,
                                          # use this config block to provide Ember specific
                                          # Handlebars configuration.
            # enabled: false              # Whether or not to use the Ember Handlebars compiler
            # path: "vendor/ember"        # location of the Ember library, this is used as
                                          # as a dependency in the compiled templates.

      ###
      # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.
      ###
      # copy:
        # extensions: ["js","css","png","jpg","jpeg","gif","html","eot","svg","ttf","woff","otf","yaml","kml","ico","htc","htm","json","txt","xml","xsd","map","md"]
    """

  validate: (config, validators) ->
    errors = []

    if validators.ifExistsIsObject(errors, "compilers config", config.compilers)
      if validators.ifExistsIsObject(errors, "compilers.extensionOverrides", config.compilers.extensionOverrides)
        for configComp in Object.keys(config.compilers.extensionOverrides)
          found = false
          for comp in @all
            if configComp is comp.base
              found = true
              break
          unless found
            errors.push "compilers.extensionOverrides, [[ #{configComp} ]] is invalid compiler."

          if Array.isArray(config.compilers.extensionOverrides[configComp])
            for ext in config.compilers.extensionOverrides[configComp]
              unless typeof ext is "string"
                errors.push "compilers.extensionOverrides.#{configComp} must be an array of strings."
          else
            unless config.compilers.extensionOverrides[configComp] is null
              errors.push "compilers.extensionOverrides must be an array."

    if validators.ifExistsIsObject(errors, "template config", config.template)
      if config.template.output and config.template.outputFileName
        delete config.template.outputFileName

      validators.ifExistsIsBoolean(errors, "template.amdWrap", config.template.amdWrap)

      validTCompilers = ["handlebars", "dust", "hogan", "jade", "underscore", "lodash", "ejs", "html", "emblem", "eco"]

      if config.template.nameTransform?
        if typeof config.template.nameTransform is "string"
          if ["fileName","filePath"].indexOf(config.template.nameTransform) is -1
            errors.push "config.template.nameTransform valid string values are filePath or fileName"
        else if typeof config.template.nameTransform is "function" or config.template.nameTransform instanceof RegExp
          # do nothing
        else
          errors.push "config.template.nameTransform property must be a string, regex or function"

      if config.template.outputFileName?
        config.template.output = [{
          folders:[""]
          outputFileName:config.template.outputFileName
        }]

      if validators.ifExistsIsArrayOfObjects(errors, "template.output", config.template.output)
        fileNames = []
        for outputConfig in config.template.output
          if validators.isArrayOfStringsMustExist errors, "template.templateFiles.folders", outputConfig.folders

            if outputConfig.folders.length is 0
              errors.push "template.templateFiles.folders must have at least one entry"
            else
              newFolders = []
              for folder in outputConfig.folders
                folder = path.join config.watch.sourceDir, config.watch.javascriptDir, folder
                unless fs.existsSync folder
                  errors.push "template.templateFiles.folders must exist, folder resolved to [[ #{folder} ]]"
                newFolders.push folder
              outputConfig.folders = newFolders

          if outputConfig.outputFileName?
            fName = outputConfig.outputFileName
            if typeof fName is "string"
              fileNames.push fName
            else if typeof fName is "object" and not Array.isArray(fName)
              for tComp in Object.keys(fName)
                if validTCompilers.indexOf(tComp) is -1
                  errors.push "template.output.outputFileName key [[ #{tComp} ]] does not match list of valid compilers: [[ #{validTCompilers.join(',')}]]"
                  break
                else
                  fileNames.push fName[tComp]
            else
              errors.push "template.outputFileName must be an object or a string."
          else
            errors.push "template.output.outputFileName must exist for each entry in array."

        if fileNames.length isnt _.uniq(fileNames).length
          errors.push "template.output.outputFileName names must be unique."

      if validators.ifExistsIsObject(errors, "template.handlebars", config.template.handlebars)
        validators.ifExistsIsArrayOfStrings(errors, "handlebars.helpers", config.template.handlebars.helpers)

        if validators.ifExistsIsObject(errors, "template.handlebars.ember", config.template.handlebars.ember)
          validators.ifExistsIsBoolean(errors, "template.handlebars.ember.enabled", config.template.handlebars.ember.enabled)
          validators.ifExistsIsString(errors, "template.handlebars.ember.path", config.template.handlebars.ember.path)

    if validators.ifExistsIsObject(errors, "copy config", config.copy)
      validators.isArrayOfStrings(errors, "copy.extensions", config.copy.extensions)

    if validators.ifExistsIsObject(errors, "coffeescript config", config.coffeescript)
      if config.isBuild
        config.coffeescript.sourceMap = false
      else
       validators.ifExistsFileExcludeWithRegexAndStringWithField(errors, "coffeescript.sourceMapExclude", config.coffeescript, 'sourceMapExclude', config.watch.javascriptDir)


    if validators.ifExistsIsObject(errors, "typescript config", config.typescript)
      validators.ifExistsIsString(errors, "typescript.module", config.typescript.module)

    if validators.ifExistsIsObject(errors, "stylus config", config.stylus)

      validators.ifExistsIsObject(errors, "stylus.define", config.stylus.define)

      validators.ifExistsIsArrayOfStrings(errors, "stylus.import", config.stylus.import)

      if validators.ifExistsIsArray(errors, "stylus.use", config.stylus.use)

        config.stylus.resolvedUse = []
        projectNodeModules = path.resolve process.cwd(), 'node_modules'
        for imp in config.stylus.use
          lib = null
          try
            lib = require imp
          catch err
            try
              lib = require path.join projectNodeModules, imp
            catch err
              console.log err
              # do nothing

          if lib is null
            errors.push "Error including stylus use [[ #{imp} ]]"
          else
            config.stylus.resolvedUse.push lib()

    validators.ifExistsIsObject(errors, "iced config", config.iced)

    errors

module.exports = new MimosaCompilerModule()