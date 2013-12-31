"use strict";
var CSSCompiler, JavaScriptCompiler, TemplateCompiler, compilers, logger, templateLibrariesBeingUsed, _, _testDifferentTemplateLibraries;

_ = require('lodash');

logger = require('logmimosa');

JavaScriptCompiler = require("./javascript/javascript");

CSSCompiler = require("./css/css");

TemplateCompiler = require("./template/template");

compilers = [];

templateLibrariesBeingUsed = 0;

_testDifferentTemplateLibraries = function(config, options, next) {
  var hasFiles, _ref;
  hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
  if (!hasFiles) {
    return next();
  }
  if (typeof config.template.outputFileName !== "string") {
    return next();
  }
  if (++templateLibrariesBeingUsed === 2) {
    logger.error("More than one template library is being used, but multiple template.outputFileName entries not found." + " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" + " template output for one of the libraries.");
  }
  return next();
};

exports.setupCompilers = function(config) {
  var compiler, extensions, exts, mod, modName, type, _i, _len, _ref, _ref1, _ref2, _results;
  _ref = config.installedModules;
  for (modName in _ref) {
    mod = _ref[modName];
    if (mod.compilerType) {
      if (logger.isDebug) {
        logger.debug("Found compiler [[ " + mod.name + " ]], adding to array of compilers");
      }
      compilers.push(mod);
    }
  }
  for (_i = 0, _len = compilers.length; _i < _len; _i++) {
    compiler = compilers[_i];
    exts = compiler.extensions(config);
    (_ref1 = config.extensions[compiler.compilerType]).push.apply(_ref1, exts);
  }
  _ref2 = config.extensions;
  _results = [];
  for (type in _ref2) {
    extensions = _ref2[type];
    _results.push(config.extensions[type] = _.uniq(extensions));
  }
  return _results;
};

exports.registration = function(config, register) {
  var compiler, compilerInstance, _i, _len;
  for (_i = 0, _len = compilers.length; _i < _len; _i++) {
    compiler = compilers[_i];
    if (logger.isDebug) {
      logger.debug("Creating compiler " + compiler.name);
    }
    compilerInstance = (function() {
      switch (compiler.compilerType) {
        case "copy":
          return new compiler.compiler(config);
        case "javascript":
          return new JavaScriptCompiler(config, compiler);
        case "template":
          return new TemplateCompiler(config, compiler);
        case "css":
          return new CSSCompiler(config, compiler);
      }
    })();
    compilerInstance.name = compiler.name;
    compilerInstance.registration(config, register);
    if (logger.isDebug) {
      logger.debug("Done with compiler " + compiler.name);
    }
  }
  if (config.template) {
    return register(['buildExtension'], 'complete', _testDifferentTemplateLibraries, config.extensions.template);
  }
};

exports.defaults = function() {
  return {
    template: {
      wrapType: "amd",
      commonLibPath: null,
      nameTransform: "fileName",
      outputFileName: "javascripts/templates",
      handlebars: {
        helpers: ["app/template/handlebars-helpers"],
        ember: {
          enabled: false,
          path: "vendor/ember"
        }
      }
    },
    copy: {
      extensions: ["js", "css", "png", "jpg", "jpeg", "gif", "html", "eot", "svg", "ttf", "woff", "otf", "yaml", "kml", "ico", "htc", "htm", "json", "txt", "xml", "xsd", "map", "md", "mp4"],
      exclude: []
    },
    typescript: {
      module: null
    },
    iced: {
      sourceMap: true,
      sourceMapDynamic: true,
      sourceMapExclude: [/\/specs?\//, /_spec.js$/],
      bare: true,
      runtime: 'none'
    },
    coco: {
      bare: true
    },
    livescript: {
      bare: true
    },
    stylus: {
      use: ['nib'],
      "import": ['nib'],
      define: {},
      includes: []
    }
  };
};

exports.placeholder = function() {
  return "\t\n\n  # iced:                       # config settings for iced coffeescript\n    # sourceMap:true            # whether to generate source during \"mimosa watch\".\n                                # Source maps are not generated during \"mimosa build\"\n                                # regardless of setting.\n    # sourceMapDynamic: true    # Whether or not to inline the source maps, this adds base64\n                                # encoded source maps to the compiled file rather than write\n                                # an extra map file.\n    # sourceMapExclude: [/\\/specs?\\//, /_spec.js$/] # files to exclude from source map generation\n    # bare:true                 # whether or not to include the top level wrapper around each\n                                # compiled iced file. Defaults to not wrapping as wrapping with\n                                # define/require is assumed.\n    # runtime:\"none\"            # No runtime boilerplate is included\n\n  # typescript:                 # config settings for typescript\n    # module: null              # how compiled tyepscript is wrapped, defaults to no wrapping,\n                                # can be \"amd\" or \"commonjs\"\n\n  # coco:                       # config settings for coco\n    # bare:true                 # whether or not to include the top level wrapper around\n                                # each compiled coco file. Defaults to not wrapping\n                                # as wrapping with define/require is assumed.\n\n  # livescript:                 # config settings for livescript\n    # bare:true                 # whether or not to include the top level wrapper around\n                                # each compiled coffeescript file. Defaults to not wrapping\n                                # as wrapping with define/require is assumed.\n\n  # stylus:                     # config settings for stylus\n    # use:['nib']               # names of libraries to use, should match the npm name for\n                                # the desired libraries\n    # import:['nib']            # Files to import for compilation\n    # define: {}                # An object containing stylus variable defines\n    # includes: []              # Files to include for compilation\n\n  # template:                         # overall template object can be set to null if no\n                                      # templates being used\n    # nameTransform: \"fileName\"       # means by which Mimosa creates the name for each\n                                      # template, options: default \"fileName\" is name of file,\n                                      # \"filePath\" is path of file after watch.sourceDir\n                                      # with the extension dropped, a supplied regex can be\n                                      # used to remove any unwanted portions of the filePath,\n                                      # and a provided function will be called with the\n                                      # filePath as input\n    # wrapType: \"amd\"                 # The type of module wrapping for the output templates\n                                      # file. Possible values: \"amd\", \"common\", \"none\".\n    # commonLibPath: null             # Valid when wrapType is 'common'. The path to the\n                                      # client library. Some libraries do not have clients\n                                      # therefore this is not strictly required when choosing\n                                      # the common wrapType.\n    # outputFileName: \"javascripts/templates\"  # the file all templates are compiled into,\n                                               # is relative to watch.sourceDir.\n\n    # outputFileName:                 # outputFileName Alternate Config 1\n      # hogan:\"hogans\"                # Optionally outputFileName can be provided an object of\n      # jade:\"jades\"                  # file extension to file name in the event you are using\n                                      # multiple templating libraries.\n\n    # output: [{                      # output Alternate Config 2\n    #   folders:[\"\"]                  # Use output instead of outputFileName if you want\n    #   outputFileName: \"\"            # to break up your templates into multiple files, for\n    # }]                              # instance, if you have a two page app and want the\n                                      # templates for each page to be built separately.\n                                      # For each entry, provide an array of folders that\n                                      # contain the templates to combine.  folders entries are\n                                      # relative to watch.sourceDir and must exist.\n                                      # outputFileName works identically to outputFileName\n                                      # above, including the alternate config, however, no\n                                      # default file name is assumed. An output name must be\n                                      # provided for each output entry, and the names\n                                      # must be unique.\n\n    # handlebars:                     # handlebars specific configuration\n      # helpers:[\"app/template/handlebars-helpers\"]  # the paths from watch.javascriptDir to\n                                      # the files containing handlebars helper/partial\n                                      # registrations\n      # ember:                        # Ember.js has its own Handlebars compilation needs,\n                                      # use this config block to provide Ember specific\n                                      # Handlebars configuration.\n        # enabled: false              # Whether or not to use the Ember Handlebars compiler\n        # path: \"vendor/ember\"        # location of the Ember library, this is used as\n                                      # as a dependency in the compiled templates.\n\n  ###\n  # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.\n  ###\n  # copy:\n    # extensions: [\"js\",\"css\",\"png\",\"jpg\",\"jpeg\",\"gif\",\"html\",\"eot\",\"svg\",\"ttf\",\"woff\",\"otf\",\"yaml\",\"kml\",\"ico\",\"htc\",\"htm\",\"json\",\"txt\",\"xml\",\"xsd\",\"map\",\"md\",\"mp4\"]\n    # exclude: []       # List of regexes or strings to match files that should not be copied\n                        # but that you might still want processed. String paths can be absolute\n                        # or relative to the watch.sourceDir. Regexes are applied to the entire\n                        # path.";
};

exports.validate = function(config, validators) {
  var err, errors, fName, fileNames, folder, fs, imp, lib, newFolders, outputConfig, path, projectNodeModules, tComp, validTCompilers, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3;
  errors = [];
  path = require('path');
  fs = require('fs');
  if (validators.ifExistsIsObject(errors, "template config", config.template)) {
    if (config.template.output && config.template.outputFileName) {
      delete config.template.outputFileName;
    }
    if (validators.ifExistsIsBoolean(errors, "template.amdWrap", config.template.amdWrap)) {
      logger.warn("template.amdWrap has been deprecated and support will be removed with a future release. Use template.wrapType.");
      if (config.template.amdWrap) {
        config.template.wrapType = "amd";
      } else {
        config.template.wrapType = "none";
      }
    }
    if (validators.ifExistsIsString(errors, "template.wrapType", config.template.wrapType)) {
      if (["common", "amd", "none"].indexOf(config.template.wrapType) === -1) {
        errors.push("template.wrapType must be one of: 'common', 'amd', 'none'");
      }
    }
    validTCompilers = ["handlebars", "dust", "hogan", "jade", "underscore", "lodash", "ejs", "html", "emblem", "eco", "ractive"];
    if (config.template.nameTransform != null) {
      if (typeof config.template.nameTransform === "string") {
        if (["fileName", "filePath"].indexOf(config.template.nameTransform) === -1) {
          errors.push("config.template.nameTransform valid string values are filePath or fileName");
        }
      } else if (typeof config.template.nameTransform === "function" || config.template.nameTransform instanceof RegExp) {

      } else {
        errors.push("config.template.nameTransform property must be a string, regex or function");
      }
    }
    if (config.template.outputFileName != null) {
      config.template.output = [
        {
          folders: [""],
          outputFileName: config.template.outputFileName
        }
      ];
    }
    if (validators.ifExistsIsArrayOfObjects(errors, "template.output", config.template.output)) {
      fileNames = [];
      _ref = config.template.output;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        outputConfig = _ref[_i];
        if (validators.isArrayOfStringsMustExist(errors, "template.templateFiles.folders", outputConfig.folders)) {
          if (outputConfig.folders.length === 0) {
            errors.push("template.templateFiles.folders must have at least one entry");
          } else {
            newFolders = [];
            _ref1 = outputConfig.folders;
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              folder = _ref1[_j];
              folder = path.join(config.watch.sourceDir, folder);
              if (!fs.existsSync(folder)) {
                errors.push("template.templateFiles.folders must exist, folder resolved to [[ " + folder + " ]]");
              }
              newFolders.push(folder);
            }
            outputConfig.folders = newFolders;
          }
        }
        if (outputConfig.outputFileName != null) {
          fName = outputConfig.outputFileName;
          if (typeof fName === "string") {
            fileNames.push(fName);
          } else if (typeof fName === "object" && !Array.isArray(fName)) {
            _ref2 = Object.keys(fName);
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              tComp = _ref2[_k];
              if (validTCompilers.indexOf(tComp) === -1) {
                errors.push("template.output.outputFileName key [[ " + tComp + " ]] does not match list of valid compilers: [[ " + (validTCompilers.join(',')) + "]]");
                break;
              } else {
                fileNames.push(fName[tComp]);
              }
            }
          } else {
            errors.push("template.outputFileName must be an object or a string.");
          }
        } else {
          errors.push("template.output.outputFileName must exist for each entry in array.");
        }
      }
      if (fileNames.length !== _.uniq(fileNames).length) {
        errors.push("template.output.outputFileName names must be unique.");
      }
    }
    if (validators.ifExistsIsObject(errors, "template.handlebars", config.template.handlebars)) {
      validators.ifExistsIsArrayOfStrings(errors, "handlebars.helpers", config.template.handlebars.helpers);
      if (validators.ifExistsIsObject(errors, "template.handlebars.ember", config.template.handlebars.ember)) {
        validators.ifExistsIsBoolean(errors, "template.handlebars.ember.enabled", config.template.handlebars.ember.enabled);
        validators.ifExistsIsString(errors, "template.handlebars.ember.path", config.template.handlebars.ember.path);
      }
    }
  }
  if (validators.ifExistsIsObject(errors, "copy config", config.copy)) {
    validators.isArrayOfStrings(errors, "copy.extensions", config.copy.extensions);
    validators.ifExistsFileExcludeWithRegexAndString(errors, "copy.exclude", config.copy, config.watch.sourceDir);
  }
  if (validators.ifExistsIsObject(errors, "coffeescript config", config.coffeescript)) {
    if (config.isBuild) {
      config.coffeescript.sourceMap = false;
    } else {
      validators.ifExistsFileExcludeWithRegexAndStringWithField(errors, "coffeescript.sourceMapExclude", config.coffeescript, 'sourceMapExclude', config.watch.javascriptDir);
      if (validators.ifExistsIsBoolean(errors, "coffee.sourceMapDynamic", config.coffeescript.sourceMapDynamic)) {
        if (config.isWatch && config.isMinify && config.coffeescript.sourceMapDynamic) {
          config.coffeescript.sourceMapDynamic = false;
          logger.debug("mimosa watch called with minify, setting coffeescript.sourceMapDynamic to false to preserve source maps.");
        }
      }
    }
  }
  if (validators.ifExistsIsObject(errors, "iced config", config.iced)) {
    if (config.isBuild) {
      config.iced.sourceMap = false;
    } else {
      validators.ifExistsFileExcludeWithRegexAndStringWithField(errors, "iced.sourceMapExclude", config.iced, 'sourceMapExclude', config.watch.javascriptDir);
      if (validators.ifExistsIsBoolean(errors, "iced.sourceMapDynamic", config.iced.sourceMapDynamic)) {
        if (config.isWatch && config.isMinify && config.iced.sourceMapDynamic) {
          config.iced.sourceMapDynamic = false;
          logger.debug("mimosa watch called with minify, setting iced.sourceMapDynamic to false to preserve source maps.");
        }
      }
    }
  }
  if (validators.ifExistsIsObject(errors, "typescript config", config.typescript)) {
    validators.ifExistsIsString(errors, "typescript.module", config.typescript.module);
  }
  if (validators.ifExistsIsObject(errors, "stylus config", config.stylus)) {
    validators.ifExistsIsObject(errors, "stylus.define", config.stylus.define);
    validators.ifExistsIsArrayOfStrings(errors, "stylus.import", config.stylus["import"]);
    validators.ifExistsIsArrayOfStrings(errors, "stylus.includes", config.stylus.includes);
    if (validators.ifExistsIsArrayOfStrings(errors, "stylus.use", config.stylus.use)) {
      config.stylus.resolvedUse = [];
      projectNodeModules = path.resolve(process.cwd(), 'node_modules');
      _ref3 = config.stylus.use;
      for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
        imp = _ref3[_l];
        lib = null;
        try {
          lib = require(imp);
        } catch (_error) {
          err = _error;
          try {
            lib = require(path.join(projectNodeModules, imp));
          } catch (_error) {
            err = _error;
            console.log(err);
          }
        }
        if (lib === null) {
          errors.push("Error including stylus use [[ " + imp + " ]]");
        } else {
          config.stylus.resolvedUse.push(lib());
        }
      }
    }
  }
  validators.ifExistsIsObject(errors, "iced config", config.iced);
  return errors;
};
