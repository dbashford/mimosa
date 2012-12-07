# 0.6.3 - December ?? 2012

### TypeScript
Added preliminary TypeScript support. It is preliminary in the sense that Mimosa is built to compile web assets, not server assets. TypeScript needs to be compiled to be run via node, so for now there is no TypeScript compilation on the server. There is probably an opportunity to have compilation of server assets to occur via an external module, but to be honest, I haven't spent a lot of time thinking this through. For the time being, when running `mimosa new`, if TypeScript and Express are chosen, the delivered server assets are JavaScript.

Also, I'm not a TypeScript developer, I've only dabbled and played. So there are likely options that the TypeScript compiler needs to support that it is not, and what I really need is feedback from TypeScripters.

Lastly, the trivial TypeScript web assets delivered with `mimosa new` are very likely not idiomatic TypeScript. If someone wants to help out with that...

### Major Changes
* Removed `removeCombine` flag from `mimosa build`.  Mimosa will now always remove all the files involved in the r.js run when the `--optimize` flag is used during `mimosa build` and it will not use r.js' removeCombined to do it.  Relates to mimosa-require #3.
* mimosa #90, upgraded default exclude to `/[/\\](\.|~)[^/\\]+$/` to cover a wider range of temp/dot/backup files, also fixed hidden issue where CSS and template compilers were ignoring `watch.exclude`
* mimosa #96, added handlebars as a server template option
* mimosa #82, fixed problem where modules could not be upgraded using `mod:install` alone

### Minor Changes
* mimosa-require #1, fixed `inferConfig: false` code path
* mimosa-live-reload #1, client script now cleaned up upon `mimosa clean`
* mimosa #94, when clean finishes, exit hard
* mimosa #95, default README for `mimosa mod:init`
* mimosa #97, added a few more things to skeleton `.gitignore`
* Removed needless dependency on lodash in mimosa-lint
* mimosa #99, mimosa config will no longer overwrite existing config in same directory
* mimosa-require #2, r.js `out` can now be removed from config
* mimosa-require #4, upgrade almond
* mimosa-require #5, require overrides from mimosa-config were remaining frozen when sent to r.js

### You'll need to...
* Update your `watch.exclude` to have the default of `[/[/\\](\.|\.#|~)[\w\.]+$/]`
* Were you using `removeCombined`?  It's no longer available as a flag, and its functionality will be the default functionality whenever the optimize flag is used and r.js is invoked.

# 0.6.2 - December 02 2012

Due to the holiday and me attending a conference all week this release took a bit.  With a bunch of the backlog a few more releases this week are likely.

### Major Changes
* New module, `mimosa-import-source`, see the module's README for details https://github.com/dbashford/mimosa-import-source

### Minor Changes
* Added new workflow before everything starts called `preBuild`.  Has two steps for now, `init` and `complete`.  Steps always easy to add.  This workflow is executed before `buildFile`, so before any individual assets are considered.
* Added `preClean`, `cleanFile`, `postClean` workflows and redirected all current cleaning behavior to use `clean`.
* Changed name of `buildDone` workflow to `postBuild` and changed all modules that registered for `buildDone` to use `postBuild`
* mimosa-require-commonjs #1, added return to end of wrap
* reworked modules page on site

### You'll need to...
* If you are doing any module work, you'll want to change your workflow details to match the new names

# 0.6.1 - November 23 2012

### Minor Changes
* Fixed #87, excluding paths via `watch.exclude` not working properly.  `watch.exclude` paths not exclude anything that starts with that path.  So you can point at a directory and anything within that directory (recursive) will be excluded.

# 0.6.0 - November 21 2012

Leaving beta. Plenty still to do, but its been decently shaken out at this point.  This release opens up the door to manipulate the r.js configuration to dynamic runtime updates.

### Major Changes
* Added EJS support for client templates.
* Big upgrade to interface for `mimosa-combine` module, released as 0.2.0 on Nov 16th
* Pushing to latest version of `mimosa-require`.  Latest version of that module pulls building of r.js run configs, and execution of r.js runs into 2 different steps in the workflow.  This means that modules can jump in the middle, programmatically and dynamically changing the r.js run config that `mimosa-require` generates before it executes.  This further empowers users of Mimosa to take control over the r.js runs.  A module can be custom built to alter the config to do just about anything.
* Added a module demonstrating the above: https://github.com/dbashford/mimosa-requirebuild-textplugin-include
* New module, `mimosa-server-reload`, for those running own node/express server, will restart server when server resources change.  https://github.com/dbashford/mimosa-server-reload
* Details below under minor changes, but across the board `mimosa-config` paths can now be both relative and absolute, and `mimosa-config` string regexs (and arrays of string regexs) are now just regexs (and arrays of regexs), which eliminates the extra escaping.

### Minor Changes
* Upped to latest versions of `server`, `live-reload` which support `server-reload`
* #85, fixed issue with windows config file detection
* To allow for workflow tasks to space out a bit more, added `betweenWriteOptimize`, `beforeOptimize`, `optimize`, and `afterOptimize` as new steps in the `add`, `update`, and `remove` workflows
* With v0.2.0 of `mimosa-web-package`, `outPath` can now be absolute as well as relative to the root of the folder.
* With v0.2.0 of `mimosa-require-commonjs`, `exclude` can now be expressed as an array containing all of the following: regex, string path relative to `watch.javascriptDir`, and/or absolute string path.  Previous is was only allowed to me a list of regex strings...not regexs.
* With v0.4.0 of `mimosa-minify`, `exclude` can now be expressed as an array containing all of the following: regex, string path relative to `watch.compiledDir`, and/or absolute string path.  Previous is was only allowed to me a list of regex strings...not regexs.
* With v0.4.1 of `mimosa-live-reload`, the `additionalDirs` config can take both absolute and relative paths to folders.
* `watch.sourceDir` and `watch.compiledDir` can now be absolute in addition to being relative to the project root.
* `watch.exclude` is now an array of regexes and strings.  Strings are paths and can be relative or absolute.

### You'll need to...
* If you were using `mimosa-combine`, take a look at the latest documentation and see if you want to upgrade to 0.2.0.  The interface is now a good deal more flexible.
* For `mimosa-require-commonjs`, the `minify` config, and the `watch` config, if you overrode exclude, your string regexs need to turn into real regexs.  Ex: ["/foo/"] => [/foo/].  And you can now use string paths, both relative and absolute.

# 0.5.5beta - November 15 2012

Purely bug fixes, both for the mimosa-require module.

### Minor Change
* Fixed #83, didn't recognize main module when it lacked config
* Fixed issue in `mimosa-require` module where workflow next callback was being called too soon.

# 0.5.4beta - November 14 2012

### Major Change
* New module `mimosa-combine`, an external module that has to be installed, not a default one, will take a folder and merge the file contents into a single file.  All configurable.  Details: https://github.com/dbashford/mimosa-combine
* New command `mod:config` will write the default configuration snippet for any module.  Ex: `mimosa mod:config server` will output the config snippet for the `mimosa-server` module.

### Minor Change
* Very tiny reorg to some module code to enable the `mimosa-combine` work

### You'll need to...
* To use the new module, simply add it to the list of modules in your `mimosa-config` or use `mimosa mod:install mimosa-combine`.  Once it is installed, use the new `mimosa mod:config` to print the config to your console so you can copy/paste it into your mimosa-config.

# 0.5.3beta - November 13 2012

Phase1 CommonJS support.  Not pure CommonJS, but CommonJS via AMD/RequireJS.  For those of you who just can't stomach wrapping all your code, but would love to take advantage of all that RequireJS provides, Mimosa can help.

### Major Changes
* CommonJS support via AMD/RequireJS using the `mimosa-require-commonjs` module.  For details: https://github.com/dbashford/mimosa-require-commonjs

### Minor Changes
* Upgrade version of `mimosa-require` to support `mimosa-require-commonjs`
* Fixed issue with requirejs plugin paths that had no dependency after the !.  Ex: `vendor/domReady!`
* #81, addressed `mimosa update` installing a bunch of stuff it not ought to have

# 0.5.2beta - November 11 2012

More minor updates while I am busy working on both TypeScript and CommonJS support.

### Minor Changes
* `mimosa-live-reload` and `mimosa-server` modules have been updated to handle the case where a user's project is already using socket.io.  If you are using socket.io on your own, using live reload, which also binds socket.io to your server, can cause some issues.  The `startServer` function in your server file, to use live reload, should currently be returning the server.  `startServer` can continue to do that if you do not need to use socket.io on your own.  If you need to use socket.io, `startServer` should return this object `{server:server, socketio:io}`, where `server` is what `startServer` returns currently, and `io` is the object returned by `socketio.listen(server)`.
* Updated the `logmimosa` version in the module skeletons.

### You'll need to...
* If you are using `mimosa-live-reload` and want to use socket.io, update your `startServer` function so that it returns `{server:server, socketio:io}`, where `server` is what `startServer` returns currently, and `io` is the object returned by `socketio.listen(server)`

# 0.5.1beta - November 09 2012

Small bug fixes. Library updates. Other miscellany.

### Minor Changes
* Library updates across the board, both in core and in the modules
* updated jquery and requirejs in the `mimosa new` skeleton
* Fixed middleware ordering issue in the delivered express server
* `mimosa config` and `mimosa new` will now rewrite your `mimosa-config` `modules` array to use whichever modules you have installed.  Previously those commands would leave the default placeholder in place for the `modules` array, but include all the config placeholders for all installed modules.

### You'll need to...
* If working with an application skeleton delivered by `mimosa new`, you'll probably want to perform the changes from this commit: https://github.com/dbashford/mimosa/commit/c97f91884ad35f34a790378ba83d8db9ce40af81 most notably the moving of the router to below the configure blocks.

# 0.5.0beta - November 06 2012

This release has a small amount of changes, but they have a decent number of breaking changes from beta4.

### Major
* In beta4 and previous, the `mimosa-server` module had live-reload functionality built in.  That functionality has been broken out of `mimosa-server` and placed into a new module, `mimosa-live-reload` which is now a default module installed with Mimosa.
* The live-reload functionality itself has been drastically altered.  No longer does Mimosa depend on another library (`watch-connect`) to provide the functionality, it has been included entirely in `mimosa-live-reload`.
* Projects that have their own server will no longer need any live-reload code in their codebase other than to include the flag in their server views to turn live-reload on and off. Mimosa handles everything else internally.  This means a lot less boilerplate code to deliver and for users to maintain in their Mimosa-based projects.
* Also, changed CSS files no longer cause a full browser reload.  Instead just the CSS is updated and repainted in the browser. So if you are developing a big single page app, no more having to start over in a page flow from page A to see CSS changes on page E.

### Minor
* Mimosa now attempts to load locally installed modules before installing them within Mimosa. If the module doesn't load (bad CoffeeScript syntax, bad require path, etc), Mimosa will not install it.  Previously, bad modules could be installed and that would cause Mimosa to be unable to subsequently start.  This does not stop bad modules from being loaded from NPM, just locally.
* Modules can now only change properties from their own config within the `mimosa-config`, both during validate() function, and during workflows.
* The default `mimosa mod:init` skeleton is now JavaScript.  With a `--coffee` or `-c` flag you can get a CoffeeScript module skeleton.

### You'll need to...
* A few changes to your codebase, see the next few bullets for details, and this commit for an idea of the sort of changes you'll need to make: https://github.com/dbashford/mimosa/commit/d21c182ff903e226d387bf8844a5580a251b4c03
* Swap the order of the live-reload scripts and the requirejs scripts in your server templates.  The live-reload scripts should be first.
* Change the name of the `/socket-enable.js` script to `/javascripts/reload-client.js`
* All of the live-reload related code can be removed from your `server` file.  This includes the `require 'watch-connect'` and the `if useReload` block.
* Replace any references to `config.server.useReload` to `config.liveReload.enabled`
* The `startServer` function needs to return the server object returned by `app.listen()`.  Without this live-reload will not work.
* The configuration for live-reload has moved.  There is no longer a `server.useReload` property.  There is now a top level `liveReload` object. Include the config snippet for the `mimosa-live-reload` module in your `mimosa-config`:

```
# liveReload:                   # Configuration for live-reload
  # enabled:true                # Whether or not live-reload is enabled
  # additionalDirs:["views"]    # Additional directories outside the watch.compiledDir
                                # that you would like to have trigger a page refresh,
                                # like, by default, static views
```

* The new default list of modules now includes `live-reload`, so you'll want to either copy the new commented out config for future use, or update your list if you've uncommented it already.

```
# modules: ['lint', 'server', 'require', 'minify', 'live-reload']
```

* The dependency on `watch-connect` is gone, so it can be removed from your `package.json`.


# 0.4.1beta - November 02 2012

### Major
* Added a `--package` flag to `mimosa build`, this does nothing other than add an `isPackage` flag to the `mimosa-config`.
* Created a new module `mimosa-web-package`, that will package up a web application. See the github repo for details: https://github.com/dbashford/mimosa-web-package  Naturally, this works with the new package flag is ticked on.  This module is not a default module, but can be used by uncommenting the `modules` config and adding `web-package`
* I've locked down the mimosa-config via Object.freeze().  Now that the app is open to module development, I felt it fairly important to keep this immutable. Now modules cannot modify the config.  I encourage the use of "use strict" in your modules so you have errors thrown when you attempt to modify the config. The module skeleton now uses "use strict". You can still alter any part of the config during the call to `validate(config)` inside a module, but that will be limited to just the portions of the config belonging to a module in a future release.

### Minor
* Upgrade all modules and the module skeleton to use the latest logmimosa.
* Added coffee-script as a dependency for mimosa's 'new' skeleton when CoffeeScript is selected as the language of choice.
* Beginning to sprinkle "use strict" around codebase.

### You'll need to...
* If you have a CoffeeScript app, for the new package module to work, you'll need to add "coffee-script": "1.3.3"  (or 1.4.0) to the list of dependencies in your `package.json` and then run `npm install` from the root of your project.

# 0.4.0beta - October 31 2012

Pluggability has arrived.  Obviously Mimosa is new and therefore its use isn't widespread, so there aren't modules besides the core set that come with Mimosa for you to use. But as time passes, I'll be building more, and in a perfect world a community of sorts develops and chips stuff in too. This release enables that.

This is another low breaking-changes release.  Don't need to do much to upgrade.  A few minor things listed below.

beta5 will be a return to adding features that have been building up while module work has commenced. Not terribly far from a 1.0.

### Major
* The `install` command has been renamed to `import` to make way for possible future different use of `install`.
* http://mimosajs.com/modules.html , modules/extensibility added and documented, few highlights...
* A new top level configuration property `modules` has been introduced.  It defaults to ['lint', 'server', 'require', 'minify']. This is what it needs to be for Mimosa to keep on doing what it always has for you, so you can leave it at its default. The modules property is how you tell Mimosa what modules to use. The default modules are external to Mimosa, but are installed with Mimosa by default.
* You can choose to remove `modules` from your project if you feel you don't need them.  For instance, if you don't want to lint your code, remove the `lint` module from the list and remove the `lint` config. This saves you having to turn if off using the lint config itself.  (In this example, if it is all commented out, you don't have to remove the lint config, but if you aren't using it, may as well clean it up!)
* You can also add new modules, modules outside the core set of Mimosa modules.  As of this writing none exist, but the point of making Mimosa pluggable was to allow for them to exist and be used.  If someone coded a `mimosa-foo` module and installed it in NPM, you can add `foo` to the list of modules. Mimosa assumes the required `mimosa-` prefix.  Mimosa will self-install any modules it finds in your list.  If it comes across a module it doesn't recognize, it will make a trip to NPM to find it.  If it doesn't find it there, it will error out.
* An entire set of commands around modules have been introduced.  They are all underneath a `mod:` prefix.

  * `mod:init [name]` - if you are interested in creating a module, this creates a module skeleton for you to use complete with heavily commented code and including docco'd docs for that code.
  * `mod:search` - This command scans npm for any `mimosa-` modules in the registry and gives you some information about them.  Use a `--verbose` flag to get more information.
  * `mod:list` - This lists all the modules installed within your Mimosa. Use a `--verbose` flag to get more information.
  * `mod:install` - This will install a Mimosa module into your Mimosa.
  * `mod:uninstall` - This will uninstall a Mimosa module from your Mimosa.

### Minor Changes
* You can now use a `mimosa-config.js` if you want. Mimosa will not give you one of those with `mimosa new` or `mimosa config`, but you can make the minor necessary charges and alter the extension of the file and Mimosa will pick it up.
* gzippo branch used as dependency with past versions of Mimosa is now gone, which will force you to upgrade/remediate as indicated in previous release
* mimosa-logger is now logmimosa to distinguish it from actual modules.  mimosa-logger will be removed from NPM to save confusion.

### You'll need to...
* At the very least, add the commented out lines of config for modules so should you want to update modules later, its there and easy to update.
```
# modules: ['lint', 'server', 'require', 'minify']   # The list of Mimosa modules to use for this application. The defaults
                                                     # (lint, server, require, minify) come bundled with Mimosa and do not
                                                     # need to be installed.  The 'mimosa-' that preceeds all Mimosa module
                                                     # names is assumed, however you can use it if you want.  If a module
                                                     # is listed here that Mimosa is unaware of, Mimosa will attempt to
                                                     # install it.
```

* Make modules of your own!  `mimosa mod:init mimosa-[nameOfModule]` and get crackin'!  Check out http://mimosajs.com/modules.html for details.
* mimosa-logger will be removed from NPM shortly, so you'll want to be sure you aren't using it.


# 0.3.1beta - October 22 2012

### Minor Changes
* Hot fix for #78.  0.3.0beta introduced an issue with user config overriding default config.

# 0.3.0beta - October 22 2012

Another step towards pluggability.  Much code yanked out of mimosa core and placed into separate npm modules (all prefixed with `mimosa-`, and easily searchable in npm by searching for `mmodule`, for 'mimosa module').  The work to do that paves the way for external modules/plugins which will be the subject of beta4.

### Major Changes
* linting, logging, serving, minifying and require/amd support have been pulled out into separate modules/plugins that are now their own npm modules. These are included as dependencies by default with mimosa. But now they can be versioned on their own, tested on their own, and so on. Each of those modules defines its own defaults, its own config placeholder (the commented out version of the config, with description, etc), and its own validation. Validation has been beefed up significantly as has feedback regarding an invalid config.
* The default config is now built on the fly based on the installed modules.  For now it'll resemble if not match what it would have been previously, but as new modules or external plugins are added, this'll allow the config to adapt.
* `watch.ignored` is now called `watch.exclude` and now takes regexes. The default has changed from `[".sass_cache"]` to `["[/\\\\]\\.\\w+$"]`.  The new default omits any files starting with a slash + a dot, like `.gitignore` or `.DS_Store`.

### Minor Changes
* Mimosa takes some of your command line flags and places them into the mimosa-config.  Two of those changed names.  `min`, a boolean that indicates whether or not the `--minify` flag was ticked, is now named `isMinify`.  `optimize`, a boolean that indicates whether or not the `--optimize` flag was ticked, is now named `isOptimize`.

### You'll need to...
* If you were overriding the `watch.ignored` property, you'll need to change it to `watch.exclude` and then address the value based on the new default.  If all you were doing with `watch.ignored` was excluding dotFiles, like `.gitignore`, then you can simply comment out the config setting as that is the new default.  If you were ignoring other things, take care to address the fact that the property now takes an array of regex strings.
* If you were not overriding the `watch.ignored` property, you will still probably want to change the placeholder text to keep from future misunderstandings should you need to exclude files.  Run `mimosa config` someplace outside your project and copy paste the updated, commented out property placeholder.
* The skeleton app delivered to you might have references to `config.optimize`
 in it that need to be changed to `config.isOptimize`.  Likewise, if for some reason you were taking advantage of `config.min`, you'll need to switch it to `config.isMinify`

# 0.2.2beta - October 18 2012

### Major Change
* #76, fixes fairly critical issue involving excluded files.

# 0.2.1beta - October 18 2012

### Major Changes
* #75, addressed LiveScript problem

### Minor Changes
* Moved server code into buildDone workflow

# 0.2.0beta - October 15 2012

### Colossal Change & Roadmap

Beta 1 to 2 was an entire refactor of the guts of Mimosa.  Pre beta2, an asset's workflow was tied tightly to compilers.  Calls to lint, calls to minify, calls to deal with amd/requirejs, etc, were all contained in the compilers.  It was a bit messy and with beta 1 decently featureful, I wanted to take the time to pull all of that apart.  What this will allow, and you'll see in beta3, is the detaching of some of that code from Mimosa entirely, putting it instead is separate npm modules to version, maintain, and eventually test apart from the larger Mimosa codebase.  Also in the next few betas one will be able to write their own modules that will be able perform tasks at certain points of an asset's workflow.

Despite many urges to the contrary, I tried not to add any new features as I wanted this refactor to be as seamless an experience from an Mimosa interface perspective as possible.  So, in all cases except for the gzippo case below, you should need to do nothing to upgrade from beta1 to 2 other than reinstall Mimosa.  beta3 should largely be the same.  I'll be pulling code out of Mimosa, and moving some things around, but there should be very few breaking changes.  beta4 will likely be a return to feature development and I've got quite the backlog of stuff building up.

Please do eagerly report any bugs you find with this release.

### Major Changes
* Removed gzippo as a dependency and use express.compress in its place.  Way more stable and fewer dependencies is goodness.
* New LiveScript compiler courtesy of @semperos

### Minor Changes
* Various messaging updates for consistency.

### You'll need to...
* If you were using gzippo in your server, it is recommended you remove it. I'll be deleting my fork sometime soon. See this commit: https://github.com/dbashford/mimosa/commit/172c2c89190bfa3b50249bfe4036cdb7f05bee1b#L3L1 to get an idea of the very simple changes you'll need to make which include removing the require for gzippo and therefore allow you to remove gzippo from your `package.json` as well.

# 0.1.2beta - October 11 2012

### Minor Changes

* #73, gzippo not pointing at fixed fork, would have caused mimosa hosted server to fail in many cases

# 0.1.1beta - October 2 2012

Still pushing forward on beta2 which, now that Mimosa is baseline feature complete, includes a massive re-write of Mimosa's internals.  Still likely a few weeks away on that.  But meanwhile...

### Minor Changes

* #72, the SASS compiler was complaining about not being installed even if no SASS was being used or compiled.  Now mimosa will only report SASS not being installed if SASS compilation is attempted.

# 0.1.0beta - September 19 2012

Beta entered! Going to be working on some bigger things for beta2 over the next few weeks and only releasing any necessary bug fixes and non-breaking features. So releases will slow down quite a bit, but that doesn't mean I'm not busy. =)

### Major Changes
* Upgraded all of Mimosa's own dependent libraries to their latest versions.
* Upgraded the skeleton express and jade to their latest versions

### Minor Changes
* #48, fixed an issue with templates using requirejs config paths.

### You'll need to...
* Entirely optional, but if you are running with your own server, you may want to run `mimosa update` to get the latest express and jade installed in your app.

# 0.0.34alpha - September 15 2012

Purely bug fixes and a little tiding of template paths which might require a little tweak to some folks mimosa-configs.

### Major Changes

* #67, #68, #69, all `mimosa-config` template paths are now relative to `watch.javascriptDir`.  Previously, for both `template.outputFileName` and `template.helperFiles`, you'd have to prepend your javascripts directory, which is already provided in `watch.javascriptDir`
* #48, the templates file will now point at your requirejs paths config setup for your client-side library if you have it.  For instance, if you have `underscore:'vendor/underscore'`, mimosa will detect that, and use `underscore` as the AMD path to your templating library. Previously you'd need to include an ugly map config.

### Minor Changes

* #64, templates file now passes through requirejs validation and registration, which means saving of handlebars templates will kick off optimization if running in `optimize` mode.
* #71, fixed issue when running with multiple CSS compilers where startup would not finish properly
* #66, fixed bug with handlebars helper files not being added to templates depedencies.  This was hot patched into .33alpha in NPM.
* #63, to address issues with live reload not working with plain html templates, live reload scripts are now included at the top of the delivered html templates.
* #70, upgraded jquery and requirejs client libraries

### You'll need to...
* If you were overriding the `template.outputFileName` or `template.helperFiles`, you'll want to update those settings to not include the path from `watch.javascriptDir`.  Those paths are now relative to `watch.javascriptDir`.
* If you were not overriding those settings, you may want to update the commened out config if you've kept it.  Just remove `javascripts/` from the `template.` settings.


# 0.0.33alpha - September 14 2012

Likely the last big update before going beta and establishing some sane versioning.  The theme with this is a big reduction in configuration for compilers, and the ability to use as many compilers as you'd like.  This one has a bunch of possible breaking changes depending on how much you might have been configuring.  Also the need for compiler configuration is mostly gone, so you'll want to address your `mimosa-config`.

### Major Changes
* The `compilers` is drastically changed and reduced; no need to configure compilers anymore.  There are no more `css`, `javascript` and `template` sections.  The `compilers` config now looks like this:

```
# compilers:
  # extensionOverrides:                 # A list of extension overrides, format is compilerName:[arrayOfExtensions]
                                        # see http://mimosajs.com/compilers.html for a list of compiler names
    # coffee: ["coff"]                  # This is an example override, this is not a default
```

It only contains overrides.  Mimosa will automatically use whichever compiler it needs to in order to compile your code based on the list of default extensions Mimosa uses for each compiler.  You can see the list of extensions here: http://mimosajs.com/compilers.html.  The `extensionOverrides` gives you the ability to tell a specific compiler to pay attention to an extension it might not otherwise be looking at.
* What the above change means, besides needing less configuration, is you can mix and match your meta-languages.  The most common use case that comes to mind is, if you want to code Stylus or SASS, but want to compile Bootstrap from its LESS source, you can now have it both ways.  You can have Bootstrap in LESS form compiling on the fly as you change its source, and you can have your own Stylus files as well doing the same thing.
* A few `compilers` config properties have survived by moving elsewhere.
`compilers.javascripts.directory` is now `watch.javascriptDir`.  `compilers.template.outputFileName` is now `template.outputFileName`, and `compilers.template.helperFiles` is now `template.helperFiles`
* `template.outputFileName` is still, by default, `javascripts/templates`, but to accommodate you possibly using multiple templating languages on your front end, `template.outputFileName` will take a hash of compiler type to path to output file from `watch.sourceDir` such as `{hogan:"js/hogans", underscore:"js/underscores"}`.
* Should multiple template libraries be used, but no hash provided, mimosa will log/growl an error to let you know you'll have template issues
* To differentiate it from Underscore, Lodash's default extension `tpl` has been changed to `tmpl`

### You'll need to...

Many possible `mimosa-config` updates.  Check out this commit to get a feel for what changed: https://github.com/dbashford/mimosa/commit/9256afd0de978df2ada9faf95cd7806f6a9ff1a3#L31L13

The details are below.  Even if you are not overriding any of these parameters and are therefore unaffected, it is suggested you make the changes to the commented out config.

Here are the details:

* Mimosa-config update: If you were using Lodash with a `.tpl` extension, you'll need to either 1) change your extensions or Underscore will do your compiling as `.tpl` is now solely Underscore's extension or 2) add a `compilers.extensionOverrides` for Lodash and `['tpl']`.
* Mimosa-config update: `watch.javascriptDir` is the new home for what was previously `compilers.javascript.directory`
* Mimosa-config update: `template.outputFileName` is then new home for what was previously `compilers.template.outputFileName`
* Mimosa-config update:`template.helperFiles` is then new home for what was previously `compilers.template.helperFiles`
* Mimosa-config update: If you are using any extensions for Mimosa's compilers that vary from the default, you'll need to add a `compilers.extensionOverrides` section that will contain a map of the name of the compiler to the extensions you wish to use for it.  Ex: `coffee:['coffee']`
* Mimosa-config update: The ONLY thing that should be in your `compilers` config is the `extensionOverrides`, everything else can be removed.

# 0.0.32alpha - September 10 2012
### Major Changes
* Added plain HTML views via EJS
* Added EJS views

### Minor Changes
* #61, bug with require call in jade-runtime

# 0.0.31alpha - September 08 2012
### Major Changes
* #60, no more Mimosa hosted views, they just don't make much sense.

### Minor Changes
* #58, recognize and validate amd wrapped commonjs paths
* #59, Hogan templates built with live reload scripts included, minor omission last release
* Mimosa views no longer delivered with title as parameter.  Best just leave that to you. =)
* Mimosa skeleton projects now pass entire config into router functions

### You'll need to...
* If you were (strangely) relying on Mimosa hosted views, you'll need views of your own.  Code your own, or check out the Mimosa skeleton for candidates: https://github.com/dbashford/mimosa/tree/master/lib/skeleton/view . You'll also need to update your `mimosa-config` to point at your new view language/tech.

# 0.0.30alpha - September 05 2012

Big changes in this release as Mimosa nears moving out of alpha.

### Major Changes
* Default base app path, `server.base`, is now blank. It was formerly `/app`.
* Added server view selection to `mimosa new`, options are `none`, `jade` and `hogan`. More coming.
* Allowing you to create a new project without a server, but with views so you have a modicum of control over the web app you build
* Three new config settings, `server.views.path` and `server.views.compileWith`, `server.views.extension`.  These are primarily for use with Mimosa's default server, but are also utilized with the delivered server as well.
* Stylus is now the default CSS meta-language
* For maximum future flexibility, now passing clone of entire mimosa config plus whatever mimosa enriches the config with (like startup flags) to startServer function of user server code

### Minor Changes
* Simplified routes and layout.jade css cache busting
* Added `hjs` as 3rd default extension for hogan
* skeleton server now using all the mimosa-config server properties

### You'll need to...
* Alter the code inside your express server to take a single config object, and then pull the fields of importance (optimize, serverPath, useReload) out of it.  See this commit for details: https://github.com/dbashford/mimosa/commit/df642531c8e5c3eb3f91e1a64ff4e568c712d8d5#L2L6
* The provided Jade template no longer has an `env` property in it, therefore, the `mimosa build --jade` command will no longer be passing an `env` meaning the compilation will fail.  Check out this commit: https://github.com/dbashford/mimosa/commit/3354a810ee0742d623ba80094186f7618050b8e4#lib/skeleton/view/jade/views/layout.jade specifically line 5 of the new layout.jade for the change you will need to make
* You do not HAVE to, but it is best if you grab the updates to the mimosa-config and paste them into your config.  https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee  The significant changes are in the server portion.  The comment for `port` changed, it is not just valid for the default server.  The default for `base` changed to blank, ''.  And the `views` section is brand new.
* If you are using the default server with the default `server.base`, you'll need to override the path to reset it to `/app` as the default was changed to be blank
* If you are using SASS, the fact that it is no longer the default extension means you need to update the Mimosa config and set `compilers.css.compileWith` to `sass` and the `compilers.css.extensions` to `['sass','scss']`
* If you are using Stylus, you can now re-comment out the `compilers.css.compileWith` and `compilers.css.extensions` configuration as it is no longer needed.


# 0.0.29alpha - September 3 2012 (this never got pushed to NPM)
### Major Changes
* #55, fixed SASS path issue

### Minor Changes
* #57, various amd path verification issues ironed out
* #56, plugin + path with extension are let through for verification without altering the extension

# 0.0.28alpha - August 30 2012
### Major Changes
* #50, integrated handlebars partials into handlebars compiler, which obviates Handlebars.registerPartial, just refer to other templates from inside your Handlebars templates and it'll just find them and use them
* #53, added `--force` flag to `clean` command to wipe entire `compiledDir`.  `clean` without force can leave behind any orphaned files.
* #54, added `--clean` flag to `watch` command, which cleans `compiledDir` before starting the watch.  Forces a recompile/recopy of all your assets.

### Minor Changes
* added `kml` to list of default extensions
* #51, not adding public directory to directory structure with `mimosa new`.  Also not erroring out when it is not present.  Will create it if it is missing.
* #52, if you name a template the same name you will now get an error/growl that this has happened.

### You'll need to...
* You don't NEED to do it, but you might want to delete all your calls to Handlebars.registerPartial.  They should prove unnecessary.

# 0.0.27alpha - August 29 2012
### Minor Change
* #49, fixing pathing issues with compiled paths outside the project directory

# 0.0.26alpha - August 29 2012
### Major Changes
* Refactor of `mimosa new` in general
* Make choosing a server part of the prompt flow rather than a flag.
* Delivered server and routes now match chosen javascript compiler (server.js if JavaScript is chosen)

### Minor Changes
* fixed #47, issues with dropped in commonjs modules and incorrect recognition of dependencies
* fixed #46, maps and config paths, living together

# 0.0.25alpha - August 26 2012
### Major Changes
* `removeCombined` works again, #43
* #27, but bigger than that.  `mimosa watch` and `mimosa build` now both have a `--minify` option.  When `--minify` is used by itself, all compiled JS assets will be mangled and compressed using Uglify.  `--minify` has a new, small config in the mimosa-config that will let you exclude certain files from minification. By default, any file containing `.min.` will not be uglified, but you can adjust the settings to include more files. When `--minify` and `--optimize` are used in conjunction, the optimization (r.js) process will have uglification turned off (`optimize:'none'`).  In combination, `--minify` and `--optimize` allow you to control which files get mangled and still take advantage of the r.js optimizer zipping all your files together and wrapping them in Almond.  There are many cases where r.js optimization cannot be used because uglify breaks a given file.  The two combined options save you from needing a custom minification strategy in those instances.

### You'll need to...
* With the new `minify` section in the mimosa-config, you will no longer have an up to date, commented out, version of the mimosa-config.  It is suggested that you find a place in your config and paste this:

```
# minify:                               # Configuration for non-require minification/compression via uglify using the --minify flag.
  # exclude:["\.min\."]                 # List of excluded file regexes when running minify using the --minify flag.  Any file
                                        # possessing ".min." in its name, like jquery.min.js, is assumed to already be minified
                                        # in a way that preserves functionality of the library, so it will be ignored.  If you have
                                        # other files that you'd like to exempt from minification, overrides this property and
                                        # include them.
```

`minify` is a top level configuration parameter.

* If you were having trouble with the r.js minifier breaking your code, take a hard look at using `--minify` and `--optimize` together in combination with the `minify.excludes` option in the mimosa-config. [This commit](https://github.com/dbashford/AngularFunMimosa/commit/1816016a3444ab960dd79c2f65b63c6bf9fdc488) shows a good example of selective exclusion of files from uglification allowing the r.js optimization to occur. In that case optimization was entirely turned off because r.js does not allow you to exclude files from being uglified.  That commit re-enables uglifications and selectively omits the file that was causing trouble.


# 0.0.24alpha - August 24 2012
### Major Changes
* More strides towards Windows compatibility, including #42, requirejs alias directory path issues
* #39, `mimosa update` should now behave and install the correct versions of libraries

### Minor Changes
* #35, `mimosa virgin` should now be ok with requirejs path verification
* #41, shim validation had stopped working awhile back, is re-enabled
* #40, issues with plain JS + handlebars fixed

### You'll need to...
* Run `mimosa update` at any point?  It was broken, there's a chance you have versions of libraries installed that you ought not have. Now that it is fixed, it is best you run `mimosa update` again to get the correct versions.

# 0.0.23alpha - August 20 2012
### Major Changes
* Major strides in Windows compatibility thanks to @brzpegasus. Solved: issues with command line help, sass compilation, and pathing issues galore.  More to come.

### Minor Changes
* #13, updated to watch-connect 0.3.4 to handle problem with file renames/removes and live reload functionality
* #36, jade compiling to right directory

### You'll need to...
* Running with a server delivered by `mimosa new`?  Then run `mimosa update` from inside your project to get the latest watch-connect

# 0.0.22alpha - August 19 2012
### Major Changes
* #29, #30, new `require.optimize.inferConfig` setting.  If you do not want Mimosa to infer anything regarding your config set `require.optimize.inferConfig` to false.  Use this setting if you have a need to alter Mimosa's config far from the defaults.  Also use this setting if you are not using JavaScript based main modules (if you are putting your config on .html for instance).  All of Mimosa's default behavior for optimization relies on the existence of a javascript based main module. If there is no main module, optimization is not run.  This will continue to be the case unless `inferConfig` is set to false.
* #14, #15, and other things never logged as issues... updated requirejs from 2.0.4 to 2.0.6.

### Breaking Changes
* Prior to this version, requirejs optimization overrides went inside the `require.optimize` setting.  Those overrides now go into a `require.optimize.overrides` setting.

# 0.0.21alpha - August 16 2012
### Major Changes
* #28, `-D`, `--debug` option added to all commands.  Much debug logging added.

### Minor Changes
* #31, change in globber significantly impacted performance, so now using both globbers and switching on `win32`
* #32, added `--removeCombined` flag to `mimosa build` to allow for cleaning up after the optimizer
* Simple running `mimosa` at the command line will now bring up help instead of doing nothing

# 0.0.20alpha - August 14 2012
### Major Changes
* #25, replaced node-glob with node-glob-whatev, which purports to work better on Windows
* #23, turning verification off also made optimization not work, this should be fixed

# 0.0.19alpha - August 13 2012
### Major Changes
* #16, can now use live reload on multiple directories.  Add an `additionaldirs` array to the `reloadOnChange` options hash with the paths to the other directories you'd like to watch.  `mimosa new` will now will now deliver code that will watch the `views` directory.

### Minor Changes
* #18, prematurely killing interval resulted in builds ending too soon, don't kill until the compilers are done
* #22, almond appearing and disappearing should no longer bother mimosa projects with huge numbers of files

### Breaking Changes
* For those using the server code delivered by Mimosa, the `reloadOnChange` options hash `exclude` now takes an array of RegExp strings rather than an array of regular strings.  Be sure to escape your regex.

# 0.0.18alpha - August 12 2012
### Minor Changes
* #20, removing firefox debug info from stylus compiled files when optimized
* #!8, when throttling, build should now exit

# 0.0.17alpha - August 11 2012
### Major Changes
* Added `watch.throttle` config setting to provide throttling for large number of adds.
* Added ability to handle `requirejs` global from require.js library.  Previously was just handling `require`.

### Minor Changes
* Added 'yaml' as another default copy extension

# 0.0.16alpha - August 10 2012
### Minor Changes
* Fixed #17, when requirejs optimization throws, subsequent runs will not automatically also throw
* Mimosa will continue to recognize path directories from require config after a file has been deleted

# 0.0.15alpha - August 9 2012
### Minor Changes
* Remove package.json on volo add
* added default npm/gitignore on project creation
* fixed problem with LESS base file determination
* added support for verifying shim paths

# 0.0.14alpha - August 6 2012
### Minor Changes
* Fixed rushed version/publish
* fixed #12, handle path arrays/fallbacks

# 0.0.13alpha - August 6 2012
### Minor Changes
* Fixed #8, recognize plugin path
* Fixed #11, validate plugin path itself
* bug on template delete

# 0.0.12alpha - August 5 2012
### Major Changes
* RequireJS handling now manages and can correctly recognize your `map` config

### Minor Changes
* Many bug fixes in require path management

# 0.0.11alpha - August 2 2012
### Major Changes
* Added plain html templating

### Minor Changes
* vendor compiled css and js won't be linted by default, like bootstrap's LESS.  Is fix, adhering to existing setting.
* update watch-connect
* 'require' is a valid dependency

# 0.0.10alpha - August 2 2012
### Major Changes
* Added new command, `install` which will use volo to install dependencies from GitHub.

# 0.0.9alpha - August 1 2012
### Major Changes
* Use calculated require dependency graph as input to optimization, removes need to provide any config whatsoever for vanilla r.js optimizes.
* Added ability to have multiple base require modules that will be auto-detected and individually optimized based on items their dependency tree being updated
* included requirejs path verification in straight js copies for files not in vendor

### Minor Changes
* added use of jade partial to version of initial add delivered when jade is selected
* write to the console when a non-vendor file is detected not wrapped in either require or define block
* write a warning to the console when a circular require dependency is detected

### Breaking Changes
* The entire optimize defaults section of the [mimosa-config](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) is now gone as Mimosa will figure it all out for you.  Anything provided inside the optimize setting will overwrite anything Mimosa calculates.

# 0.0.8alpha - July 30 2012
### Major Changes
* added `jade` flag to `build` command that when provided will attempt to compile `index.jade`
* removed coffee-lint

### Minor Changes
* Upgraded Chokidar
* watch-connect back to npm

# 0.0.7alpha - July 28 2012
### Major Changes
* Added `update` command to make it easy for people to keep their dependent post-new-command modules up to date with Mimosa's skeleton

# 0.0.6alpha - July 27 2012
### Major Changes
* Added new RequireJS path verification ([see documentation](https://github.com/dbashford/mimosa#requirejs-support))

### Minor Changes
* Moved the require code around a bit in the Mimosa code base
* slightly altered the require code surrounding the client template libraries

### Breaking Changes
The `require` config has been broken up. What was previously directly under `require` is now under `require.optimize`.  A new `verify` option lives under the `require` config.

If you have not overridden any `require` configuration, then you are fine.  However, for future reference, it is suggested that you copy the new [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) `require` block over top of yours.

If you have overridden the `require` configuration, then you'll want to adjust your current `require` object to be inside the `optimize` object, and you'll want to add the new `verify` option as it exists in the [mimosa-config.coffee](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).
