"use strict";
var MimosaCompilerModule, baseDirRegex, fs, logger, path, wrench, _,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

path = require('path');

fs = require('fs');

_ = require('lodash');

logger = require('logmimosa');

wrench = require('wrench');

baseDirRegex = /([^[\/\\\\]*]*)$/;

MimosaCompilerModule = (function() {
  MimosaCompilerModule.prototype.all = [];

  function MimosaCompilerModule() {
    this._testDifferentTemplateLibraries = __bind(this._testDifferentTemplateLibraries, this);
    this.all = wrench.readdirSyncRecursive(__dirname).filter(function(f) {
      return /-compiler.js$/.test(f) || /copy.js$/.test(f);
    }).map(function(f) {
      var comp, file;
      file = path.join(__dirname, f);
      comp = require(file);
      comp.base = path.basename(file, ".js").replace('-compiler', '');
      if (comp.base !== "copy") {
        comp.type = baseDirRegex.exec(path.dirname(file))[0];
      } else {
        comp.type = "copy";
      }
      return comp;
    });
  }

  MimosaCompilerModule.prototype.registration = function(config, register) {
    var compiler, _i, _len, _ref;
    _ref = this.configuredCompilers.compilers;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      compiler = _ref[_i];
      if (compiler.registration != null) {
        compiler.registration(config, register);
      }
    }
    if (config.template) {
      return register(['buildExtension'], 'complete', this._testDifferentTemplateLibraries, config.extensions.template);
    }
  };

  MimosaCompilerModule.prototype._testDifferentTemplateLibraries = function(config, options, next) {
    var hasFiles, _ref;
    hasFiles = ((_ref = options.files) != null ? _ref.length : void 0) > 0;
    if (!hasFiles) {
      return next();
    }
    if (typeof config.template.outputFileName !== "string") {
      return next();
    }
    if (!this.templateLibrariesBeingUsed) {
      this.templateLibrariesBeingUsed = 0;
    }
    if (++this.templateLibrariesBeingUsed === 2) {
      logger.error("More than one template library is being used, but multiple template.outputFileName entries not found." + " You will want to configure a map of template.outputFileName entries in your config, otherwise you will only get" + " template output for one of the libraries.");
    }
    return next();
  };

  MimosaCompilerModule.prototype._compilersWithoutCopy = function() {
    return this.all.filter(function(comp) {
      return comp.base !== "copy";
    });
  };

  MimosaCompilerModule.prototype.compilersByType = function() {
    var comp, compilersByType, _i, _len, _ref;
    compilersByType = {
      css: [],
      javascript: [],
      template: []
    };
    _ref = this._compilersWithoutCopy();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      comp = _ref[_i];
      compilersByType[comp.type].push(comp);
    }
    return compilersByType;
  };

  MimosaCompilerModule.prototype.setupCompilers = function(config) {
    var Compiler, allCompilers, allOverriddenExtensions, base, compiler, compilers, ext, extHash, extensions, type, _i, _j, _len, _len1, _ref, _ref1, _ref2, _ref3;
    allOverriddenExtensions = [];
    _ref = config.compilers.extensionOverrides;
    for (base in _ref) {
      ext = _ref[base];
      allOverriddenExtensions.push.apply(allOverriddenExtensions, ext);
    }
    logger.debug("All overridden extension [[ " + (allOverriddenExtensions.join(', ')) + "]]");
    allCompilers = [];
    extHash = {};
    compilers = this.all.filter(function(comp) {
      return comp.base !== "none";
    });
    if (config.template === null) {
      compilers = compilers.filter(function(comp) {
        return comp.type !== "template";
      });
    }
    for (_i = 0, _len = compilers.length; _i < _len; _i++) {
      Compiler = compilers[_i];
      extensions = Compiler.base === "copy" ? config.copy.extensions : config.compilers.extensionOverrides[Compiler.base] === null ? (logger.debug("Not registering compiler [[ " + Compiler.base + " ]], has been set to null in config."), false) : config.compilers.extensionOverrides[Compiler.base] != null ? config.compilers.extensionOverrides[Compiler.base] : _.difference(Compiler.defaultExtensions, allOverriddenExtensions);
      if (extensions) {
        compiler = new Compiler(config, extensions);
        allCompilers.push(compiler);
        _ref1 = compiler.extensions;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          ext = _ref1[_j];
          extHash[ext] = compiler;
        }
        (_ref2 = config.extensions[Compiler.type]).push.apply(_ref2, extensions);
      }
    }
    _ref3 = config.extensions;
    for (type in _ref3) {
      extensions = _ref3[type];
      config.extensions[type] = _.uniq(extensions);
    }
    logger.debug("Compiler/Extension hash \n " + extHash);
    this.configuredCompilers = {
      compilerExtensionHash: extHash,
      compilers: allCompilers
    };
    return this;
  };

  MimosaCompilerModule.prototype.getCompilers = function() {
    return this.configuredCompilers;
  };

  MimosaCompilerModule.prototype.defaults = function() {
    return {
      compilers: {
        extensionOverrides: {}
      },
      template: {
        nameTransform: "fileName",
        amdWrap: true,
        outputFileName: "templates",
        handlebars: {
          helpers: ["app/template/handlebars-helpers"],
          ember: {
            enabled: false,
            path: "vendor/ember"
          }
        }
      },
      copy: {
        extensions: ["js", "css", "png", "jpg", "jpeg", "gif", "html", "eot", "svg", "ttf", "woff", "otf", "yaml", "kml", "ico", "htc", "htm", "json", "txt", "xml", "xsd", "map", "md"]
      },
      typescript: {
        module: null
      },
      coffeescript: {
        sourceMap: true,
        sourceMapExclude: [/\/specs?\//, /_spec.js$/],
        bare: true
      },
      iced: {
        bare: true,
        runtime: 'none'
      },
      coco: {
        bare: true
      },
      stylus: {
        use: ['nib'],
        "import": ['nib'],
        define: {},
        includes: []
      },
      sass: {
        node: false
      }
    };
  };

  MimosaCompilerModule.prototype.placeholder = function() {
    return "\t\n\n  # compilers:\n    # extensionOverrides:       # A list of extension overrides, format is:\n                                # [compilerName]:[arrayOfExtensions], see\n                                # http://mimosajs.com/compilers.html for list of compiler names\n      # coffee: [\"coff\"]        # This is an example override, this is not a default, must be\n                                # array of strings\n\n  # coffeescript:                    # config settings for coffeescript\n    # sourceMap:true                 # whether to generate source during \"mimosa watch\".\n                                     # Source maps are not generated during \"mimosa build\"\n                                     # regardless of setting.\n    # sourceMapExclude: [/\\/specs?\\//, /_spec.js$/] # files to exclude from source map generation\n    # bare:true                      # whether or not to include the top level wrapper around\n                                     # each compiled coffeescript file. Defaults to not wrapping\n                                     # as wrapping with define/require is assumed.\n\n  # iced:                       # config settings for iced coffeescript\n    # bare:true                 # whether or not to include the top level wrapper around each\n                                # compiled iced file. Defaults to not wrapping as wrapping with\n                                # define/require is assumed.\n    # runtime:\"none\"            # No runtime boilerplate is included\n\n  # typescript:                 # config settings for typescript\n    # module: null              # how compiled tyepscript is wrapped, defaults to no wrapping,\n                                # can be \"amd\" or \"commonjs\"\n\n  # coco:                       # config settings for coco\n    # bare:true                 # whether or not to include the top level wrapper around\n                                # each compiled coffeescript file. Defaults to not wrapping\n                                # as wrapping with define/require is assumed.\n\n  # stylus:                     # config settings for stylus\n    # use:['nib']               # names of libraries to use, should match the npm name for\n                                # the desired libraries\n    # import:['nib']            # Files to import for compilation\n    # define: {}                # An object containing stylus variable defines\n    # includes: []              # Files to include for compilation\n\n  # sass:                       # config settings for sass\n    # node: false               # whether or not to use the node SASS compiler instead of the\n                                # Ruby one, which must be installed with Ruby.\n\n  # template:                         # overall template object can be set to null if no\n                                      # templates being used\n    # nameTransform: \"fileName\"       # means by which Mimosa creates the name for each\n                                      # template, options: default \"fileName\" is name of file,\n                                      # \"filePath\" is path of file after watch.javascriptDir\n                                      # with the extension dropped, a supplied regex can be\n                                      # used to remove any unwanted portions of the filePath,\n                                      # and a provided function will be called with the\n                                      # filePath as input\n    # amdWrap: true                   # Whether or not to wrap the compiled template files in\n                                      # an AMD wrapper for use with require.js\n    # outputFileName: \"templates\"     # the file all templates are compiled into, is relative\n                                      # to watch.javascriptDir.\n\n    # outputFileName:                 # outputFileName Alternate Config 1\n      # hogan:\"hogans\"                # Optionally outputFileName can be provided an object of\n      # jade:\"jades\"                  # file extension to file name in the event you are using\n                                      # multiple templating libraries. The file extension must\n                                      # match one of the default compiler extensions or one of\n                                      # the extensions configured for a compiler in the\n                                      # compilers.extensionOverrides section above.\n\n    # output: [{                      # output Alternate Config 2\n    #   folders:[\"\"]                  # Use output instead of outputFileName if you want\n    #   outputFileName: \"\"            # to break up your templates into multiple files, for\n    # }]                              # instance, if you have a two page app and want the\n                                      # templates for each page to be built separately.\n                                      # For each entry, provide an array of folders that\n                                      # contain the templates to combine.  folders entries are\n                                      # relative to watch.javascriptDir and must exist.\n                                      # outputFileName works identically to outputFileName\n                                      # above, including the alternate config, however, no\n                                      # default file name is assumed. An output name must be\n                                      # provided for each output entry, and the names\n                                      # must be unique.\n\n    # handlebars:                     # handlebars specific configuration\n      # lib: null                     # an opportuntity to provide a specific version of the\n                                      # handlebars compiler for template compilation. Use\n                                      # node's require syntax to include a version that you\n                                      # have included in your project.\n      # helpers:[\"app/template/handlebars-helpers\"]  # the paths from watch.javascriptDir to\n                                      # the files containing handlebars helper/partial\n                                      # registrations\n      # ember:                        # Ember.js has its own Handlebars compilation needs,\n                                      # use this config block to provide Ember specific\n                                      # Handlebars configuration.\n        # enabled: false              # Whether or not to use the Ember Handlebars compiler\n        # path: \"vendor/ember\"        # location of the Ember library, this is used as\n                                      # as a dependency in the compiled templates.\n\n  ###\n  # the extensions of files to copy from sourceDir to compiledDir. vendor js/css, images, etc.\n  ###\n  # copy:\n    # extensions: [\"js\",\"css\",\"png\",\"jpg\",\"jpeg\",\"gif\",\"html\",\"eot\",\"svg\",\"ttf\",\"woff\",\"otf\",\"yaml\",\"kml\",\"ico\",\"htc\",\"htm\",\"json\",\"txt\",\"xml\",\"xsd\",\"map\",\"md\"]";
  };

  MimosaCompilerModule.prototype.validate = function(config, validators) {
    var comp, configComp, err, errors, ext, fName, fileNames, folder, found, imp, lib, newFolders, outputConfig, projectNodeModules, tComp, validTCompilers, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _len6, _m, _n, _o, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    errors = [];
    if (validators.ifExistsIsObject(errors, "compilers config", config.compilers)) {
      if (validators.ifExistsIsObject(errors, "compilers.extensionOverrides", config.compilers.extensionOverrides)) {
        _ref = Object.keys(config.compilers.extensionOverrides);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          configComp = _ref[_i];
          found = false;
          _ref1 = this.all;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            comp = _ref1[_j];
            if (configComp === comp.base) {
              found = true;
              break;
            }
          }
          if (!found) {
            errors.push("compilers.extensionOverrides, [[ " + configComp + " ]] is invalid compiler.");
          }
          if (Array.isArray(config.compilers.extensionOverrides[configComp])) {
            _ref2 = config.compilers.extensionOverrides[configComp];
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              ext = _ref2[_k];
              if (typeof ext !== "string") {
                errors.push("compilers.extensionOverrides." + configComp + " must be an array of strings.");
              }
            }
          } else {
            if (config.compilers.extensionOverrides[configComp] !== null) {
              errors.push("compilers.extensionOverrides must be an array.");
            }
          }
        }
      }
    }
    if (validators.ifExistsIsObject(errors, "template config", config.template)) {
      if (config.template.output && config.template.outputFileName) {
        delete config.template.outputFileName;
      }
      validators.ifExistsIsBoolean(errors, "template.amdWrap", config.template.amdWrap);
      validTCompilers = ["handlebars", "dust", "hogan", "jade", "underscore", "lodash", "ejs", "html", "emblem", "eco"];
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
        _ref3 = config.template.output;
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          outputConfig = _ref3[_l];
          if (validators.isArrayOfStringsMustExist(errors, "template.templateFiles.folders", outputConfig.folders)) {
            if (outputConfig.folders.length === 0) {
              errors.push("template.templateFiles.folders must have at least one entry");
            } else {
              newFolders = [];
              _ref4 = outputConfig.folders;
              for (_m = 0, _len4 = _ref4.length; _m < _len4; _m++) {
                folder = _ref4[_m];
                folder = path.join(config.watch.sourceDir, config.watch.javascriptDir, folder);
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
              _ref5 = Object.keys(fName);
              for (_n = 0, _len5 = _ref5.length; _n < _len5; _n++) {
                tComp = _ref5[_n];
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
    }
    if (validators.ifExistsIsObject(errors, "coffeescript config", config.coffeescript)) {
      if (config.isBuild) {
        config.coffeescript.sourceMap = false;
      } else {
        validators.ifExistsFileExcludeWithRegexAndStringWithField(errors, "coffeescript.sourceMapExclude", config.coffeescript, 'sourceMapExclude', config.watch.javascriptDir);
      }
    }
    if (validators.ifExistsIsObject(errors, "typescript config", config.typescript)) {
      validators.ifExistsIsString(errors, "typescript.module", config.typescript.module);
    }
    if (validators.ifExistsIsObject(errors, "sass config", config.sass)) {
      validators.ifExistsIsBoolean(errors, "sass.node", config.sass.node);
    }
    if (validators.ifExistsIsObject(errors, "stylus config", config.stylus)) {
      validators.ifExistsIsObject(errors, "stylus.define", config.stylus.define);
      validators.ifExistsIsArrayOfStrings(errors, "stylus.import", config.stylus["import"]);
      validators.ifExistsIsArrayOfStrings(errors, "stylus.includes", config.stylus.includes);
      if (validators.ifExistsIsArrayOfStrings(errors, "stylus.use", config.stylus.use)) {
        config.stylus.resolvedUse = [];
        projectNodeModules = path.resolve(process.cwd(), 'node_modules');
        _ref6 = config.stylus.use;
        for (_o = 0, _len6 = _ref6.length; _o < _len6; _o++) {
          imp = _ref6[_o];
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

  return MimosaCompilerModule;

})();

module.exports = new MimosaCompilerModule();
