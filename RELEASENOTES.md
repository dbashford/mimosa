## 2.0.0 (Future) - Dec/Jan

* All compilers will be pulled out of mimosa core into separate modules. So there will me a mimosa-coffeescript, a mimosa-sass, etc.
* The desired compilers will need to be added to the `modules` list as they will no longer "just work". This is the single downside of externalizing the compilers.
* This will dramatically shrink Mimosa's footprint. Hopefully making folks feel a little less like they are downloading all of NPM.
* This should also make it much more clear how to add compilers of your own.  Pre-2.0 that would require a pull request to mimosa core, now you'll create your own module.
* Some configuration will move to the compilers.  For instance, the `compiler` config, which has settings for library overrides (when you want to, for instance, provide a specific version of Handlebars) or extension overrides (when you want to use `.c` as a CoffeeScript extension) will move into the specific compilers. This will decrease complexity in mimosa's compiler management, but it also just makes sense.
* `mimosa new` will get an overhaul that'll allow it to pull in needed compilers and build a mimosa-config based on those external modules.
* The Handlebars compiler will likely be broken into two modules, one for Handlebars and one for Ember-Handlebars.

NOTE: While development of `2.0` takes place, some `2.0` targeted modules (like mimosa-coffeescript) may show up in NPM as I build things out. I'll make it clear that those are 2.0 targeted modules. Using them with `1.3.x` will likely cause some odd results.

## 1.3.2 - Dec 20 2013

### Major Changes
* [mimosa #315](https://github.com/dbashford/mimosa/issues/315). Mimosa will now accept node flags upon startup.  The list of available flags are `--debug`, `--debug-brk`, `-gc`, `--expose-gc`, `--gc-global`, `--harmony`, `--harmony-proxies`, `--harmony-collections`, `--harmony-generators`, and `--prof`.

### Minor Changes
* [mimosa #327](https://github.com/dbashford/mimosa/issues/327). To deconflict Mimosa's `--debug` and node's `--debug`, moved Mimosa from `-D/--debug` to `-D/--mdebug`.

## 1.3.1 - Dec 19 2013

### Major Changes
* __New Skeleton__: [markdown-math](https://github.com/xixixao/mimosa-markdown-math). A simple skeleton for markdown and math.
* __New Skeleton__: [minimal-foundation](https://github.com/xixixao/mimosa-minimal-foundation). A skeleton with basic Foundation integration (only CSS) and Foundation intro template page.
* [mimosa #323](https://github.com/dbashford/mimosa/issues/323). Updated CSS compilation so that included `.css` files will trigger proper CSS compiles. Now if a `.css` file is included in a Stylus or Less file, and that CSS file changes, the parent Stylus/Less file will be recompiled.

### Minor Changes
* [mimosa #325](https://github.com/dbashford/mimosa/issues/325). The copy "compiler" now has a 2nd setting for files not to copy. You could use the `watch.exclude` for this, but that prevents files from even being considered by Mimosa.  The new `copy.exclude` does not prevent those files that were to be copied from being considered, it just prevents them from being copied.  When would you want to process a copied file but not copy it?  With [mimosa #323](https://github.com/dbashford/mimosa/issues/323) `.css` files can now trigger Stylus/Less recompiles.  You may wish for a `.css` file to be processed so it can trigger that recompile, but you may not wish for that `.css` file to be copied itself.
* [mimosa #324](https://github.com/dbashford/mimosa/issues/324). Better error messaging in default server when 404 occurs.
* [mimosa #320](https://github.com/dbashford/mimosa/issues/320). Improved documentation for [mimosa-client-jade-static](https://github.com/dbashford/mimosa-client-jade-static#functionality) to explain an idiosyncrasy of that module and optimization that results in the minify modules attempting to minify non javascript.
* [mimosa #319](https://github.com/dbashford/mimosa/issues/319). Adjusted Mimosa's embedded server so that it would not throw errors when attempting to access certain bad URLs.
* [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple), [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). The Testem version has been updated (from `0.4.2` to `0.6.1`) for testem-simple and testem-require has the updated testem-simple. Testem has had a huge amount of updates since it was last updated, but a fundamental problem with folder/directory watching inside testem prevented the library from being updated. That issue has been fixed.
* [mimosa-jshint #2](https://github.com/dbashford/mimosa-jshint/pull/2). Added `globals` support to jshint via PR.
* [mimosa-bower #33](https://github.com/dbashford/mimosa-bower/pull/33). Fixing some Windows path issues with custom path mapping.

## 1.3.0 - Dec 12 2013

`1.3` marks the beginning of a total compiler rewrite. This first step, `1.3`, has no impact on users but lays the ground work for pulling all of the compilers out of mimosa's core library and into external modules. That will take place as part of `2.0` which will likely follow a 2-4 weeks after `1.3`.

No functionality or config changes for `1.3` from `1.2.4`, but enough of the core has been rewritten to warrant bumping up a minor version.

## 1.2.4 - Dec 11 2013

### Minor Changes
* [mimosa #322](https://github.com/dbashford/mimosa/issues/322). Fixed issue with `mimosa new` + underscore/lodash micro templates.

## 1.2.3 - Dec 11 2013

### Minor Changes
* [mimosa #321](https://github.com/dbashford/mimosa/issues/321). Made adjustments to the regex for config replacement to fix config for `mimosa new` + no server.
* [mimosa-testem-simple #4](https://github.com/dbashford/mimosa-testem-simple/issues/4). Added `port` setting which will allow for running both testem ci and testem at the same time without port collisions.
* [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require/). Bumped to contain the latest testem-simple.
* [mimosa-web-package #8](https://github.com/dbashford/mimosa-web-package/issues/8). Check if server properties are present before using them. Fixes issue where if server config present but server module is not would cause build to hang/crash.

## 1.2.2 - Dec 4 2013

### Minor Changes
* [mimosa #318](https://github.com/dbashford/mimosa/issues/318). Added `mp4` to the list of default `copy.extensions`.

## 1.2.1 - Nov 30 2013

### Minor Changes
* [mimosa-bower #31](https://github.com/dbashford/mimosa-bower/issues/31). Improved error messaging and fixed issue where Mimosa would stop processing when Bower install would fail because of git not being detected.

## 1.2.0 - Nov 30 2013

### Major Changes
* [mimosa-minify-css](https://github.com/dbashford/mimosa-minify-css) and [mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js) are now default modules.
* [mimosa-minify](https://github.com/dbashford/mimosa-minify) is no longer a default module
* The only current Mimosa users that would be effected by this are those that are currently using the default module set (`modules` is commented out) and providing a `minify.exclude` config.
* The current minify module will still be supported.  If you are using it, it will still function.
* For upgrade details [visit the site](http://mimosa.io/about.html).

## 1.1.10 - Nov 27 2013

### Major Changes
* __New Module__:
[mimosa-minify-css](https://github.com/dbashford/mimosa-minify-css). This new module duplicates the CSS minification/cleaning functionality of the [mimosa-minify](https://github.com/dbashford/mimosa-minify) module, omitting the CSS functionality.  And it is written in JS rather than Coffee. With `1.2`, this module will be one of two modules replacing the mimosa-minify module as Mimosa defaults.
* __New Module__:
[mimosa-minify-js](https://github.com/dbashford/mimosa-minify-js). This new module duplicates the JavaScript minification functionality of the [mimosa-minify](https://github.com/dbashford/mimosa-minify) module, omitting the CSS functionality.  And it is written in JS rather than Coffee. With `1.2`, this module will be one of two modules replacing the mimosa-minify module as Mimosa defaults.  Also, mimosa-minify did not create source maps for any files that didn't already have source maps, like compiled CoffeeScript files.  This module will create source maps for all minified JavaScript files, whether they are transpiled files or not.

### Minor Changes
* [mimosa-require #26](https://github.com/dbashford/mimosa-require/issues/26). Fixing issue with require module not cleaning up r.js built files.

## 1.1.9 - Nov 27 2013

### Minor Changes
* [mimosa #314](https://github.com/dbashford/mimosa/issues/314). `mimosa new` was not properly building the `modules` array for the mimosa-config when modules other than the internal build-ins were installed.  Small typo.
* [mimosa-require #25](https://github.com/dbashford/mimosa-require/issues/25). Adjusting comments in config placeholder.

## 1.1.8 - Nov 24 2013

### Major Changes
* A new configuration property was added to the root of the config: `requiredMimosaVersion`.  It is `null` by default.  When it is provided, Mimosa will force the specific version be installed to run Mimosa.  This allows large project teams to force everyone to stay on a specific version, and to force them to upgrade in unison.
* __New Skeleton__: [minimal](https://github.com/lachenmayer/mimosa-minimal). A stripped down skeleton for quick startup. No server or prescribed MVC.

## 1.1.7 - Nov 23 2013

### Minor Changes
* [mimosa-live-reload #4](https://github.com/dbashford/mimosa-live-reload/pull/4). Fix for cross domain support.

## 1.1.6 - Nov 20 2013

* [mimosa #313](https://github.com/dbashford/mimosa/issues/313). Fixed issue where Mimosa was not recognizing valid Stylus `@import` syntax without quotes.

## 1.1.5 - Nov 20 2013

### Minor Changes
* [mimosa-live-reload #3](https://github.com/dbashford/mimosa-live-reload/pull/3). Added cross domain support to live reload.
* [mimosa-testem-require #7](https://github.com/dbashford/mimosa-testem-require/pull/7), [mimosa-testem-simple #3](https://github.com/dbashford/mimosa-testem-simple/issues/3). Killer PR added config flags for testem-require that allows for PhantomJS runs of testem to be turned off during `mimosa watch` and `mimosa build`. This lets testem-require just do the heavy lifting of setting up your application's testing suite but not do the execution.

## 1.1.4 - Nov 08 2013

### Major Changes
* [mimosa #309](https://github.com/dbashford/mimosa/issues/309). A new `-e/--errorout` flag was added to the `build` command. When the `errorout` flag is used, and a file fails compile (js, css, template), the build will exit immediately with a non-zero status.  Use this flag for your automated builds.  If `errorout` is not used, `mimosa build` will continue compiling files and will return a zero status.

## 1.1.2/1.1.3 - Nov 08 2013

Small patch fixes to fix problems with `1.1.1`.

## 1.1.1 - Nov 07 2013

### Minor Changes
* [mimosa #310](https://github.com/dbashford/mimosa/issues/310). Fixed issue with mimosa-minify where `.css` files (not `.styl` or `.scss` etc) were not being minified on startup for `mimosa watch` or during `mimosa build`.

## 1.1.0 - Nov 04 2013

Two new modules, mimosa-jshint and mimosa-csslint, as of this release will replace the old mimosa-lint.  This simplifies the config a good deal, and makes it much easier to remove one without removing the other.

mimosa-lint will still be supported, but as an external module. I won't be updating it all unless asked.

Details on how to upgrade [on the site](http://mimosa.io/about.html).

### Major Changes
* __New Module__:
[mimosa-jshint](https://github.com/dbashford/mimosa-jshint). A pure [JSHint](http://www.jshint.com/) module. With release `1.1.0`, this module replaces the JavaScript portion of the current mimosa-lint module as a default Mimosa module. It preserves all of the same functionality of the JS pieces of mimosa-lint, but with a simplified config. This module also allows those who were not interested in mimosa-lint's full feature set, but want JSHint, to add it by itself.  See the site for [details on how to configure this module](http://mimosa.io/configuration.html).
* __New Module__:
[mimosa-csslint](https://github.com/dbashford/mimosa-csslint). A pure [CSSLint](http://csslint.net/) module. With release `1.1.0`, this module replaces the CSS portion of of the current mimosa-lint module as a default Mimosa module. It preserves all of the same functionality of CSS pieces of mimosa-lint, but with a simplified config. This module also allows those who were not interested in mimosa-lint's full feature set but want CSSLint to simply add it.  See the site for [details on how to configure this module](http://mimosa.io/configuration.html).
* The two modules listed above are now default modules.
* mimosa-lint is no longer a default module

### Minor Changes
* [mimosa-post-hook](https://github.com/dbashford/mimosa-post-hook). Updated the module to allow for configuring which `postBuild` workflow step to run the commands on.  This'll allow you to, for instance, run some command before the server starts.  Also added the ability to selectively choose when to continue Mimosa workflow processing for each command.  This will allow you to wait for a timeout or a certain message in stdout before resuming Mimosa workflow steps.  So, for example, you can ensure Mongo is started before starting the server.

### Breaking Changes
* If you have a __commented__ out mimosa-config `modules` property, these two new modules will be activated. If you need a quick fix, uncomment your `modules` array and leave it unchanged. You will continue using the older lint module. Otherwise checkout [the 1.1 Release information on the site](http://mimosa.io/about.html) to upgrade and use the new modules.
* If you have __uncommented__ your `modules` property, then you will be using whatever modules you have listed __and no changes are necessary__.  To upgrade to the new lint/hint modules and stop using the previous one, checkout [the 1.1 Release information on the site](http://mimosa.io/about.html).

## 1.0.12 - Oct 31 2013

### Major Changes
* __New Module__:
[mimosa-spritesmith](https://github.com/ddlsmurf/mimosa-spritesmith). From the community comes this fork of [mimosa-sprite](https://github.com/dbashford/mimosa-sprite) which shifts the spriting dependency to spritesmith and provides retina support. Great docs, check it out!

### Minor Changes
* Dependency updates: stylus, nib, less, iced-coffee, ractive, underscore, dust, emblem, jade.  All updated to latest.  Remember, if the latest versions don't work for you, you can always [supply a specific version](http://mimosa.io/configuration.html#compilers) that works for you.
* [mimosa-combine #11](https://github.com/dbashford/mimosa-combine/pull/11). From a PR, addresses white spaces issues in combined files.

## 1.0.11 - Oct 30 2013

### Minor Changes
* [mimosa #305](https://github.com/dbashford/mimosa/issues/305). Adjustment to `mimosa mod:config` command to allow it to see locally installed modules. Previously if you had modules in a project's `node_modules` directory (as opposed to installed inside Mimosa itself, as with `mimosa mod:install`), `mod:config` would not be able to find them.

## 1.0.10 - Oct 30 2013

### Minor Changes
* [mimosa #304](https://github.com/dbashford/mimosa/issues/304), [mimosa-testem-require #6](https://github.com/dbashford/mimosa-testem-require/issues/6). Allowing mimosa-config default config object settings to be `null`. Previously mimosa-config object properties had to be `{}`.  Setting them to `null` would cause Mimosa to error out when the property needed to be overridden.

## 1.0.9 - Oct 28 2013

### Major Changes
* [mimosa-bower #28](https://github.com/dbashford/mimosa-bower/issues/28). A new config setting, `bower.copy.unknownMainFullCopy`, is a quick fix for bower packages that do not declare a `main`.  The right way to solve this problem is to set up a `mainOverride` that pulls out the specific files you want, but in lieu of that, this will simply copy the entire package into the appropriate place.  It defaults to `false`.
* __New Module__:
[mimosa-requirebuild-module-include](https://github.com/twill88/mimosa-requirebuild-module-include). A module for including module dependencies into an r.js build.
* __New Module__:
[mimosa-requirebuild-textplugin-module-include](https://github.com/twill88/mimosa-requirebuild-textplugin-module-include). Long, though descriptive, name for a new module that will add your text plugin dependencies to your requirejs `modules` config.

## 1.0.8 - Oct 21 2013

### Major Changes
* __New Module__: [mimosa-post-hook](https://github.com/dbashford/mimosa-post-hook). A module for executing scripts/commands when `mimosa watch` finishes its startup.
* [mimosa-require #24](https://github.com/dbashford/mimosa-require/issues/24). Addressed some issues that popped up with the recent `modules` support. If running `mimosa watch`, you could only run optimization successfully one time when `watch` started up. Every subsequent run (after saving a file for instance) would error out. That has been addressed, however one of the pieces to fix this was to disable, by default, creation of source maps during `modules`-based r.js runs (non-`modules` runs will continue to have source maps). Even after addressing most of the issues, source maps still made it difficult to keep developing while `mimosa watch` was running. Source maps can be forced on using `require.optimize.overrides`, and they will work, but only that first time.  Work will be done int he future to address source maps + `modules` dev, likely at the same time mimosa-require is updated to the latest requirejs.

### Minor Changes
* [mimosa-sprite](https://github.com/dbashford/mimosa-sprite). Removed need to return object from `options` function. Also added debugging.
* [mimosa-require #24](https://github.com/dbashford/mimosa-require/issues/24). `mimosa clean` will now properly clean up after `modules` runs.

## 1.0.7 - Oct 19 2013

### Minor Changes
* [mimosa-live-reload #2](https://github.com/dbashford/mimosa-live-reload/issues/2). mimosa-live-reload would fail if attempting to write `reload-client.js` to the output folder if the output folder didn't exist.  Now it'll create the folder if its not there.
* [mimosa-require #23](https://github.com/dbashford/mimosa-require/issues/23). `mimosa clean` now does a better job of cleaning up over r.js runs involving a `modules` config.

## 1.0.6 - Oct 17 2013

### Major Changes
* __New Module__: [mimosa-sprite](https://github.com/dbashford/mimosa-sprite). This module will generate CSS sprite images and corresponding stylesheets.

### Minor Changes
* [mimosa #301](https://github.com/dbashford/mimosa/issues/301). `.css` files were not being properly handled during `mimosa watch` after the initial startup. An update to a `.css` file would not update the file in the `watch.compiledDir`.

## 1.0.5 - Oct 17 2013

### Minor Changes
* [mimosa #300](https://github.com/dbashford/mimosa/pull/300), [mimosa #293](https://github.com/dbashford/mimosa/issues/293). `mimosa mod:list` should now function behind a proxy thx to PR.

## 1.0.4 - Oct 15 2013

### Minor Changes
* [mimosa-require #22](https://github.com/dbashford/mimosa-require/issues/22). Fixed a stray async call in the tracker code.
* [mimosa #296](https://github.com/dbashford/mimosa/issues/296). Mimosa now shuts down the `clean` watcher after the cleaning is done. The `clean` watcher not being shut down meant that any files added (like from a bower install) after the cleaner was finished might get removed as soon as they are compiled to `watch.compiledDir` and you'd end up with randomly missing files.

## 1.0.3 - Oct 15 2013

### Minor Changes
* [server-template-compile #3](https://github.com/dbashford/mimosa-server-template-compile/issues/3). Module now includes all the templating languages it needs rather than depending on other modules.
* [mimosa #295](https://github.com/dbashford/mimosa/pull/295) and [mimosa #292](https://github.com/dbashford/mimosa/issues/292). PR included support for Stylus' [`include css`](https://github.com/LearnBoost/stylus/issues/448) functionality.
* [mimosa #293](https://github.com/dbashford/mimosa/pull/293). Haven't fixed #293, but error messaging has been improved. `mimosa mod:list` will not work behind a proxy and previously the command would error out. Now there is some more helpful messaging.
* [mimosa #291](https://github.com/dbashford/mimosa/pull/291). PR created support for the [Stylus url function](http://learnboost.github.io/stylus/docs/functions.url.html). Configuration pass through to the url functionality is available via `stylus.url`

    ```coffeescript
    stylus:
      url:
        limit: 40000
    ```

## 1.0.2 - Oct 9 2013

### Major Changes
* __New Skeleton__: [backbone-topcoat](https://github.com/mftaher/mimosa-backbone-topcoat). New skeleton integrates some simple Backbone boilerplate with Top Coat. Coded in CoffeeScript/Stylus/Underscore with Hogan/Express on the server.  Check it out!

### Minor Changes
* [skelmimosa #6](https://github.com/dbashford/skelmimosa/issues/6). Fixed issue with folder not removing on windows.
* [skelmimosa #12](https://github.com/dbashford/skelmimosa/issues/12). Unpublished old `mimosa-skeleton` module from NPM.

## 1.0.1 - Oct 8 2013

### Major Changes
* __New Module__: [mimosa-plato](https://github.com/dbashford/mimosa-plato). A module for running the [Plato](https://github.com/dbashford/mimosa-plato) static analysis tool against your JavaScript.
* __New Module__: [mimosa-js-valiadte](https://github.com/dbashford/mimosa-js-validate). Uses Esprima to catch validation and syntax errors in JavaScript.  Great if you choose to not use a linter.

### Minor Changes
* [mimosa-require](https://github.com/dbashford/mimosa-require/). Fixed issue where regular non-optimized builds, `mimosa build`, would cause dependency checking to fail.

## 1.0.0 Final - Oct 8 2013

### Minor Changes
* [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). Fixed issue with random diffs popping up in the `test-variables` file.
* [mimosa #271](https://github.com/dbashford/mimosa/issues/271). mimosa-web-package now builds the proper tar command when using tools like git bash on windows.  Previous it made a Windows `cmd` compatible command, now it goes *nix if using an emulator.

## 1.0.0-rc.7 - Oct 2 2013

Planning to release `1.0 Final` on Monday Oct 7, but wanted to get the following updates in sooner than that.

### Major Changes
* __New Example App__: [MimomsaDynamicRequire](https://github.com/dbashford/MimosaDynamicRequire). A quick little example showing how to use Mimosa to build a requirejs app with dynamic modules.

### Minor Changes
* [mimosa #287](https://github.com/dbashford/mimosa/issues/287). Better error messaging out of mimosa-require when require.js paths config isn't proper.
* [mimosa #285](https://github.com/dbashford/mimosa/issues/285). If no file of a given language needed to be compiled, then the compiler for that language would not be required in during startup. When the server file of that language was required in order to start the server, it could not be compiled. Now compiler libs are brought in whether or not a file needs to be compiled.
* [mimosa #283](https://github.com/dbashford/mimosa/issues/283). Added a real 'none' server option to `mimosa new` that will legit not provide server options.  Previously the 'none' option was actually Mimosa's embedded server rather than no server at all. The expectation is that you will point the `watch.compiledDir` to some `public` folder of yours.

## 1.0.0-rc.6 - Sept 23 2013

### Major Changes
* __New Module__: [mimosa-es6-module-transpiler](https://github.com/dbashford/mimosa-es6-module-transpiler). Use ES6 module syntax today! This module will compile your ES6 module syntax down to AMD, CommonJS or globals.
* [mimosa #284](https://github.com/dbashford/mimosa/issues/284). Enabling the new mimosa-require tracking functionality by default. Also updated the `mimosa new` `.gitignore` to exclude the `tracking.json` by default.  Many `.mimosa` artifacts benefit from being in source control, but this file does not.
* [mimosa-require #21](https://github.com/dbashford/mimosa-require/issues/21). mimosa-require can now gracefully handle r.js module setups.  A new `modules` property has been added to `require.optimize`. When a modules array is provided, mimosa-require will alter the r.js run config appropriately.

## 1.0.0-rc.5 - Sept 16 2013

### Major Changes
* __New Module__: [mimosa-require-lint](https://github.com/dbashford/mimosa-require-lint). This module will determine if you have any unused AMD dependencies in your `define` callback or in your CommonJS code wrapped in the AMD CommonJS wrapper. In the future it may house other AMD related checks. If you have any ideas, open an issue!
* __New Skeleton__: [zappa-basic](https://github.com/dbashford/MimosaZappaSkeleton). A few people over the past few months have asked how to use a [Zappa](http://zappajs.github.io/zappajs/) as a server, with live reload and such. So here ya go!
* [mimosa #281](https://github.com/dbashford/mimosa/issues/281). `mimosa mod:list` has received an overhaul.  It now shows all Mimosa modules from NPM. Installed modules are sorted to the top. Pass an `-i/--installed` to just see those you have installed.  Calls to retrieve module information go to a Heroku app that caches the NPM information every hour.  This removes `npm` as a dependency for Mimosa internally.  `mod:list` will also inform you if you have an out of date dependency.
* [mimosa #281](https://github.com/dbashford/mimosa/issues/281). The command `mimosa mod:search` has been dropped in lieu of simple improvements to `mod:list` mentioned above.

### Minor Changes
* [mimosa-require #20](https://github.com/dbashford/mimosa-require/issues/20). Much of mimosa-require is tailored to 1-main-to-1-output builds. But if a single run results in multiple outputs, mimosa-require had issues with messaging properly and with cleaning up the aftermath.  That is fixed with this. Hoping to include more 1-run-many-output support soon.
* [mimosa-require #19](https://github.com/dbashford/mimosa-require/issues/19). mimosa-require will now validate paths in `packages` config.
* [mimosa #282](https://github.com/dbashford/mimosa/issues/282). Handling `./` at front of templates path alias resulting in wrong AMD path being written to `templates.js`.
* [mimosa #280](https://github.com/dbashford/mimosa/issues/280). Programmatically setting `dynamicSourceMaps` to `false` if `minify` flag is used as Uglify cannot take dynamic source maps as input.
* [mimosa-import-source #5](https://github.com/dbashford/mimosa-import-source/issues/5). Added a `usePolling` flag to config to help slow down CPU burn on Windows machines.

## 1.0.0-rc.4 - Sept 09 2013

Deprecating `template.amdWrap` as a config setting but still will support it in the short term.  That is the only breaking-ish change in this release.

### Huge Changes
* __New Module__: [mimosa-browserify](https://github.com/jonet/mimosa-browserify). Until now Mimosa's CommonJS support has been via AMD wrapping and using RequireJS. With the addition of a browserify module, Mimosa can now boast full CommonJS support and another means besides r.js to bundle your applications. To support the browserify module, the change mentioned below regarding CommonJS support for templates was necessary.  This closes the oldest open Mimosa ticket for [CommonJS support](https://github.com/dbashford/mimosa/issues/77).

### Major Changes
* __New Skeleton__: [browserify-example](https://github.com/JonET/mimosa-browserify-example). To show how to use the new browserify module @JonET whipped up a quick example project that takes the vanilla `mimosa new` app and converts it to use CommonJS/Browserify instead of AMD/RequireJS.
* __New Skeleton__: [ember-commonjs](https://github.com/JonET/mimosa-ember-commonjs). A basic Ember app wired together using CommonJS. The skeleton will grow, but for now it shows how to configure Mimosa to use browserify and commonjs to create your Ember.js application.
* [mimosa #273](https://github.com/dbashford/mimosa/issues/273). Mimosa now provides the option to output the combined template file as a commonjs module. The former `amdWrap:true/false` setting has been replaced with a `wrapType` setting that takes `amd`, `common` or `none`. Outputting a commonjs compliant templates files is the extent of the core Mimosa commonjs support.  For instance, for now, Mimosa will not output a CommonJS compliant library file.
* [mimosa-bower #25](https://github.com/dbashford/mimosa-bower/issues/25). The `bower:install` command has changed. Previously it did exactly what `mimosa bower` did.  It installed everything in the `bower.json`. Now it can be used to install new libraries.  For example: `mimosa bower:install backbone,lodash#1.2.1`. Notice multiple can be installed by comma-delimiting them, and version numbers can be used. The result of this will be the libraries will be installed, but also the project's `bower.json` `dependencies` object will be updated. To update `devDependencies` instead, use the `-d` flag.

### Minor Changes
* [mimosa-require](https://github.com/dbashford/mimosa-require/). Made some updates to the tracking functionality released with `rc.3`. Tracked paths are now relative to `watch.compiledDir` instead of the root of the project. Path separators are normalized to unix style to avoid diffs cross-project. Also to prevent unnecessary file diffs, the tracking file object keys are sorted. Will probably enable tracking by default after another release.
* [mimosa-require #17](https://github.com/dbashford/mimosa-require/issues/17). Issue with `map` validation addressed.

## 1.0.0-rc.3 - Sept 03 2013

### Huge Changes
* [mimosa-require #14](https://github.com/dbashford/mimosa-require/issues/14). Mimosa needed to have all of its JavaScript rebuilt with every startup so that mimosa-require could rebuild its dependency graph. With this release, mimosa-require is capable of tracking your project's dependency information between Mimosa runs. mimosa-require will persist to the file system the information it needs to startup without requiring all JavaScript files to be processed/compiled. A new `tracking` configuration has been added to the `require` config. When `require.tracking.enabled` is set to `true`, mimosa-require will keep track of dependency information on the file system.

  `require.tracking.enabled` defaults to `false` for now while this feature is new and still being worked out. It will default to `true` in the near future after its had some time to shake out.

  If files are moved or changed while Mimosa is not running, `tracking` may get out of sync. When this happens, run a `mimosa clean` and mimosa-require will rebuild its tracking information.

### Major Changes
* __New Module__: [mimosa-coffeelint](https://github.com/dbashford/mimosa-coffeelint) allows you to lint your coffeescript.
* [mimosa #273](https://github.com/dbashford/mimosa/issues/273). By default Mimosa now outputs source maps as dynamic. So no `.map` or `.src` files are written, instead the map and source are base64 encoded and placed inside the JavaScript output. This means 66% less CoffeeScript related I/O and 66% fewer HTTP requests. Fewer HTTP requests also means less clutter in your debugger. Dynamic source maps also allow for tools like browserify to utilize the source maps as part of bundling.

  Both the `coffeescript` and `iced` configurations now have a `sourceMapDynamic` flag which defaults to `true`.  Flip it back to `false` to go back to old multi-file source map support.

### Minor Changes
* [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple/) now builds its list of spec files at the beginning of the workflow. To use mimosa-testem-require with `rc.3` you will need version `v0.6.5` of mimosa-testem-require, otherwise mimosa-testem-require may not properly discover spec files.
* [mimosa](https://github.com/dbashford/mimosa/). Mimosa modules can now force Mimosa to run a clean at the beginning of `mimosa watch` starting up.

### Upgrade Info / Breaking Changes
* If you are using mimosa-testem-simple, you will want to make sure you upgrade to `v0.6.5`.

## 1.0.0-rc.2 - Aug 29 2013

Some possible breaking changes with how template paths are handled, so check out the breaking changes below.

### Major Changes
* [mimosa #272](https://github.com/dbashford/mimosa/issues/272). `template` paths are now relative to `watch.sourceDir` rather than `watch.javascriptDir` so template files can be placed outside of `watch.javascriptDir` and the template output files can go anywhere inside `watch.sourceDir`. This is possibly a breaking change.  Previous defaults are preserved.

### Minor Changes
* [mimosa-client-jade-static #1](https://github.com/dbashford/mimosa-client-jade-static/issues/1). Because of the change for [mimosa #272](https://github.com/dbashford/mimosa/issues/272), client-jade-static templates can be in any folder inside `watch.sourceDir`.
* Upgraded [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple/) and [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require/) to latest version of testem.
* [mimosa-testem-require #3](https://github.com/dbashford/mimosa-testem-require/issues/3). The `testscript` command now outputs with relative paths.
* [mimosa-testem-require #4](https://github.com/dbashford/mimosa-testem-require/issues/4). The `testscript` command now errors out gracefully if mimosa-testem-require isn't a part of a project.
* [mimosa-bower](https://github.com/dbashford/mimosa-bower/). Upgraded to latest bower and managed API changes.

### Upgrade Info / Breaking Changes
* You have __no changes to make__ if you are not using any micro-templaters or did not override any of Mimosa's defaults.
* If you were overriding the location of output files, you will __need to alter the paths__ as the relative path has changed from `watch.javascriptDir` to `watch.sourceDir`
* If you were providing `folders` to bundle into different output files, you will __need to alter the paths__ as the relative path has changed from `watch.javascriptDir` to `watch.sourceDir`

## 1.0.0-rc.1 - Aug 27 2013

`1.0` upgrade info below.

1.0! Real excited to get to this milestone. All of the built-in Mimosa modules have also been ticked up to `1.0`.

### Huge Changes
* [mimosa #254](https://github.com/dbashford/mimosa/issues/254). [mimosa-bower](https://github.com/dbashford/mimosa-bower/) is now a default module. `mimosa new` will deliver a `bower.json` and not deliver `jquery.js`
 or `require.js`.

### Major Changes
* [mimosa #268](https://github.com/dbashford/mimosa/issues/268). The command `mimosa mod:init` has been removed from Mimosa. New Mimosa skeletons have been added for creating a JavaScript Mimosa module and a CoffeeScript Mimosa module. `mimosa skel:new mimosa-module-javascript` and `mimosa skel:new mimosa-module-coffeescript`
* [mimosa #268](https://github.com/dbashford/mimosa/issues/268). Mimosa now comes with built-in support for the [Ractive](http://www.ractivejs.org/) templating library. Two-way data binding ftw!
* [mimosa #258](https://github.com/dbashford/mimosa/issues/258). Removed `node-sass` as a dependency as it occasionally breaks Mimosa installs.  It also forces node `v0.10`. Mimosa still supports `node-sass`, but it needs to be provided to it via the `compilers.libs.sass` configuration parameter.
* [mimosa #256](https://github.com/dbashford/mimosa/issues/256). All `require` calls for compilers are now delayed until the initial file of that type is encountered. This should slightly improve startup time, but it will also stop compiler confusion. Occasionally, for instance, iced-coffee-script would compile files on behalf of coffee-script.
* [mimosa #255](https://github.com/dbashford/mimosa/issues/255). All compilers can now be provided via the mimosa-config by way of the `compilers.libs` setting. This allows users of Mimosa to use specific versions of compilers if Mimosa's current default versions aren't satisfactory.

### Minor Changes
* [mimosa #259](https://github.com/dbashford/mimosa/issues/259). Updated skeleton registry JSON, added details for future skeleton browsing web app front-end use.
* [mimosa-bower #22](https://github.com/dbashford/mimosa-bower/issues/22). mimosa-bower will now watch your `bower.json` and when changes to it occur, kick off a bower install.
* All Mimosa modules

### Upgrade Info / Breaking Changes
* A minor inconvenience, and not very breaking, but if you have a Mimosa project that has not overridden the `modules` array, then when you upgrade to `1.0` `bower` will now be included in your project. You'll get a message indicating that a `bower.json` cannot be found. If you do not want Bower, simply uncomment the `modules` array and leave `bower` out.
* `template.handlebars.lib` and `template.emblem.lib` have been moved to `compilers.libs.handlebars` and `compilers.libs.emblem` respectively.
* Using `node-sass`? It is no longer bundled with Mimosa. To use `node-sass` you must `npm install` to install it into your project and then use `compilers.libs.sass` to `require` it in.

## 0.14.15 - Aug 25 2013

### Major Changes
* [mimosa #270](https://github.com/dbashford/mimosa/issues/270). Fixed an issue where mimosa-server was holding onto references to every request object that came through it, causing memory to grow at a steady pace.
* [mimosa-server-reload #2](https://github.com/dbashford/mimosa-server-reload/issues/2). While fixing the above issue, I stumbled upon the fix to this long running issue, which should make mimosa-server-reload once more 100% usable.

### Minor Changes
* [mimosa-bower #21](https://github.com/dbashford/mimosa-bower/issues/21). Handling case when `bower.json` for component has incorrect path in `main`.
* [mimosa-bower #20](https://github.com/dbashford/mimosa-bower/issues/20). Sorting the last installed files to avoid file diffs between installs.
* [mimosa-bower #19](https://github.com/dbashford/mimosa-bower/issues/19). Removing `copy.exclude` from tracking checks because it contains file paths. Cross-project diffs will occur.
* [mimosa-bower #18](https://github.com/dbashford/mimosa-bower/issues/18). Changed `pathMod` defaults to an empty array due to possible harmful side effects of defaults on `mainOverride` object mappings.
* [mimosa-bower #17](https://github.com/dbashford/mimosa-bower/issues/17). Fixed issue where binary files were getting jacked up when copying to `assets` directory.

## 0.14.14 - Aug 18 2013

### Minor Changes
* [mimosa-lint #8](https://github.com/dbashford/mimosa-lin/issues/8). Fixed bug where non-coffee/iced js langauges could not set custom options.

## 0.14.13 - Aug 17 2013

### Minor Changes
* [mimosa-require #13](https://github.com/dbashford/mimosa-require/issues/13). Fixed issue where attempting to debug log the r.js run config could result in a circular reference and bomb the process out.
* [mimosa-client-jade-static #3](https://github.com/dbashford/mimosa-client-jade-static/issues/3). Added new configuration to client-jade-static module that allows for configuring the input and output extensions.

## 0.14.12 - Aug 15 2013

### Minor Changes
* [mimosa-require](https://github.com/dbashford/mimosa-require). Fix for feature added in previous release.

## 0.14.11 - Aug 14 2013

### Minor Changes
* [mimosa #264](https://github.com/dbashford/mimosa/issues/264). Fixed a problem on Windows where RequireJS main files that were nested inside project structure were not being built properly.
* [mimosa-require](https://github.com/dbashford/mimosa-require). Added function to convert full system paths into the proper AMD path given a project's requirejs path aliases and directory aliases.

## 0.14.10 - Aug 12 2013

### Major Changes
* [mimosa #260](https://github.com/dbashford/mimosa/issues/260). Added several options to help manage file watching causing CPU issues. `watch.interval` determines the polling interval for non-binary files.  `watch.binaryInterval` determines the polling for binary files.  And `watch.usePolling` determines whether or not to actually use polling. For more information, check out the [GitHub issue](https://github.com/dbashford/mimosa/issues/179) where this was discussed.
* __New Module__: [mimosa-dependency-graph](https://github.com/brzpegasus/mimosa-dependency-graph). Simply add this module to your module list (that's it!) and you'll get some super cool d3 graph visualizations of your application's dependency graph. This module utilizes the information gathered by the mimosa-require module and layers on some d3 hotness.  Use this tool to figure out which modules have the most dependencies (refactoring targets) and which modules are depended on the most (testing targets).

## 0.14.9 - Aug 10 2013

### Major Changes
* [mimosa #262](https://github.com/dbashford/mimosa/issues/262). Added support for server-side dust templates.

### Minor Changes
* [mimosa-bower #15](https://github.com/dbashford/mimosa-bower/issues/15). Switched `forceLatest` default to `true` and now provide warning message with details when `forceLatest` results in a selection being made between multiple libraries.

## 0.14.8 - Aug 08 2013

### Minor Changes
* mimosa. Updated client template libraries mimosa delivers on `watch`.
* mimosa. Update `package.json` dependency versions for `mimosa new` projects.

## 0.14.7 - Aug 08 2013

### Major Changes
* __New Module__: [mimosa-s3-deployer](https://github.com/Costent/mimosa-s3-deployer). An installation plugin that will copy static assets into s3.
* __New Module__: [mimosa-requirebuild-include](https://github.com/CraigCav/mimosa-requirebuild-include). Used to add extra assets not picked up by r.js to your r.js bundled application.
* __New Skeleton__: [ember-peepcode](https://github.com/breathe/mimosa-peepcode) is now in the skeleton registry. It is a port of the Ember app from the Peepcode series to Mimosa.  Uses Ember, Emblem, Foundation, Stylus and CoffeeScript on the client. Bower for managing vendor assets. Testem and QUnit for testing. Backed by Express and Jade. `mimosa skel:new ember-peepcode [nameOfFolder]`
* __New Skeleton__: [ui-component](https://github.com/dbashford/MimosaUIComponentSkeleton). This skeleton is a great starting place if using Mimosa to build reusable UI components. It bundles bower, and includes testing with Mocha/Chai via Testem. It also includes the `library-package` module for bundling your application. `mimosa skel:new ui-component [nameOfFolder]`
* __New Skeleton__: [durandal-node](https://github.com/dbashford/Durandal-Mimosa-Node-Skeleton). If you want to use Durandal on the front-end, but want to back it with node/Express, this is the skeleton for you. It includes Handlebars server views and also  bundles bower. `mimosa skel:new durandal-node [nameOfFolder]`

### Minor Changes
* mimosa. Updated compiler dependencies: jade, emblem, dustjs-linkedin, underscore, iced-coffee-script, livescript, less, and stylus.
* [mimosa-bower #16](https://github.com/dbashford/mimosa-bower/issues/16). Added `-c/--cache` flag to `bower:clean`.
* [mimosa-import-source/mimosa #179](https://github.com/dbashford/mimosa/issues/179). New config added to mimosa-import-source to help alleviate CPU churn on (mostly) Windows machines.  `interval` and `binaryInterval` have been added to allow the file system watching polling to be slowed down.
* [mimosa-require-library-package #3](https://github.com/dbashford/mimosa-require-library-package/issues/3). Whether or not to clean the `outFolder` is now configurable.


## 0.14.6 - Aug 03 2013

### Major Changes
* [mimosa #249](https://github.com/dbashford/mimosa/issues/249). `mimosa-skeleton` is now `skelmimosa` and is a default Mimosa module. Now all `skel:` commands are available by default.  It is a embedded module though, not a project module, so, like with compilers, there is no need to add it to a `modules` array in your projects.
* [mimosa #250](https://github.com/dbashford/mimosa/issues/250). The `build` command now has an `install` flag (`-i`/`--install`). No modules take advantage of it...yet.
* New Demo App! [mimosa-peepcode](https://github.com/breathe/mimosa-peepcode) is a port of the Ember app from the Peepcode series to Mimosa.  Uses Ember, Emblem, Foundation, Stylus and CoffeeScript on the client. Bower for managing vendor assets. Testem and QUnit for testing. Backed by Express and Jade.

### Minor Changes
* [mimosa-bower](https://github.com/dbashford/mimosa-bower). Upgraded to latest bower.
* [mimosa-bower #12](https://github.com/dbashford/mimosa-bower/issues/12). `mimosa bower` will now error out gracefully if run on a project that does not have the `bower` module installed.
* [mimosa-bower #13](https://github.com/dbashford/mimosa-bower/issues/13). Default placement of mimosa-bower assets, like track files and the `bower_components` folder will now be inside a `.mimosa/bower` folder.
* [mimosa-bower #14](https://github.com/dbashford/mimosa-bower/issues/14). Added `forceLatest:false` as a config option under `copy`.  Use this to quickly resolve any conflicts between library versions.
* [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple). Upgraded testem to latest version.
* [mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). Upgraded mimosa-testem-simple to latest version.
* [mimosa-require-library-package #2](https://github.com/dbashford/mimosa-require-library-package/issues/2). Added a `mainConfigFile` option to allow those not using the `require.commonConfig` to set that without needing to use `overrides`.

### You'll need to...
* If using mimosa-bower and upgrading to the latest version, you'll want to remove the mimosa-bower related files in `.mimosa`, namely all the ones starting with `bower-` and ending in `.json`.  If you have a `bower_components` directory, you'll want to remove that too.

## 0.14.5 - Aug 01 2013

### Major Changes
* New Module: [mimosa-require-library-package](https://github.com/dbashford/mimosa-require-library-package). Use this module when using RequireJS/AMD to build library code for use in other web applications. This module will package up your library in several formats: AMD-shimmed, with dependencies, and without.

### Minor Changes
* [mimosa #247](https://github.com/dbashford/mimosa/issues/247). You can now provide a specific version of Emblem to use for compilation by `require`ing in a version in your application.

    ```coffeescript
    template:
      emblem:
        lib: require('emblem')
    ```

* [mimosa #243](https://github.com/dbashford/mimosa/issues/243). Tweaked last releases change.  `mimosa config` now writes a file named `mimosa-config-commented.coffee` with a bit of text at the top mentioning that the file is for reference only.

## 0.14.4 - Jul 29 2013

### Major Changes
* [mimosa #246](https://github.com/dbashford/mimosa/issues/246). Altered `mimosa config` command to always deliver a `mimosa-config.defaults.coffee`. This will let you keep the `mimosa-config.coffee/js` as trim as possible while keeping a `defaults` file around to use as reference. `mimosa config` will always overwrite whatever `defaults` file is in place.  A simple `git diff` will tell you what if any config has changed.  `mimosa config` will continue to write a `mimosa-config.coffee` if one is not present as a way to include Mimosa into an existing app.

### Minor Changes
* [mimosa-client-jade-static #2](https://github.com/dbashford/mimosa-client-jade-static/issues/2). `.html.jade` compilation can now take a `context` object for compilation. Previously jade files had to be purely static.
* [mimosa-bower #10](https://github.com/dbashford/mimosa-bower/issues/10). Tracking will no longer pay attention to resolved `pathFull` property of `bower` config.  This was causing installs to occur every time across project teams.
* [mimosa-bower #11](https://github.com/dbashford/mimosa-bower/issues/11). Tracking now keeps track of all installed files in a given bower install for easy cleaning when the `bower_components` directory is not available.

## 0.14.3 - Jul 28 2013

### Major Changes
* [mimosa-bower #7](https://github.com/dbashford/mimosa-bower/issues/7).  mimosa-bower will now keep track of your `bower.json` and the `bower` section of the mimosa-config between installs and detect if any changes have been made before executing an install. This slightly naive though effective feature allows `clean` to be set to `true` and still get the benefit of not re-installing every module with every Mimosa start.  Allowing `clean:true` means that the often enormous `bower_components` directory can be left out of your project.  The major downside is that when the `bower.json` or the `bower` mimosa-config section change in _any_ way, the full install will occur resulting in many files being overwritten with identical files. This should not cause any problems other than being a little unnerving.

  As part of this change, the default for `clean` is now `true`.  A new config property, `trackChanges`, has been added to turn this feature on and off.  When off mimosa-bower still falls back to Bower detecting on its own whether or not installs need to occur, but for that to work, `clean` must be set to `false`.

  More details on the [mimosa-bower README](https://github.com/dbashford/mimosa-bower/)

### Minor Changes
* [mimosa #244](https://github.com/dbashford/mimosa/issues/244). New `livescript` root level config available in the mimosa-config. That config is passed right into the LiveScript compiler.  By default, `bare` is set to `true` as module wrapping is assumed.

## 0.14.2 - Jul 27 2013

### Minor Changes
* [mimosa #240](https://github.com/dbashford/mimosa/issues/240). Made default `package.json` name meet npm standards.
* [mimosa #241](https://github.com/dbashford/mimosa/issues/241). Upgraded the ember compiler for handlebars `1.0.12`
* [mimosa](https://github.com/dbashford/mimosa/). Upgraded to latest Emblem: `0.3.0`.
* [mimosa-lint #7](https://github.com/dbashford/mimosa-lin/issues/7). Added `expr:true` to the list of default rules for CoffeeScript and IcedCoffeeScript.
* Demo Apps: Upgraded the [mimosa-ember-emblem](https://github.com/dbashford/mimosa-ember-emblem-templates) demo app and the [mimosa-testem](https://github.com/emirotin/mimosa-ember) demo apps to sync with library updates.
* [mimosa-testem-require #2](https://github.com/dbashford/mimosa-testem-require/issues/2). Sorting specs before writing to avoid random file diffs.
* [mimosa-bower](https://github.com/dbashford/mimosa-bower/). Any `mainOverride` files or paths that do not exist for a package will generate a log message.
* [mimosa-bower #8](https://github.com/dbashford/mimosa-bower/issues/8).  Updated docs and error message regarding necessary location of `bower.json`
* [mimosa-bower #6](https://github.com/dbashford/mimosa-bower/issues/6).
The `mainOverrides` array can now be handed object(s) that map input package file/folder straight to output package file/folder for maximum flexibility. See the [alternate config](https://github.com/dbashford/mimosa-bower#alternate-config) for an example.
* [mimosa-bower #5](https://github.com/dbashford/mimosa-bower/issues/5).  `strategy` can now be package specific.  See the [alternate config](https://github.com/dbashford/mimosa-bower#alternate-config) for an example.
* [mimosa-bower #3](https://github.com/dbashford/mimosa-bower/issues/3).  `mainOverride` paths can now be folders and all the folders contents will be copied.

## 0.14.1 - Jul 23 2013

### Minor Changes
* [mimosa #238](https://github.com/dbashford/mimosa/issues/238). Only requiring in node-sass if node-sass is configured and erroring out with better messaging.
* [mimosa-bower #1](https://github.com/dbashford/mimosa-bower/issues/1). mimosa-bower was using the wrong metadata data point to determine which folder Bower was placing its installed assets.

## 0.14.0 - Jul 22 2013

Big release!  Two new modules and improvements to mimosa core to accommodate those modules.  Also some improvements to mimosa-require.

### New Modules
* [mimosa-bower](https://github.com/dbashford/mimosa-bower). Bower integration. Allows for importing and version/dependency management for vendor scripts. Details on the [GitHub page](https://github.com/dbashford/mimosa-bower#overview).
* [mimosa-just-copy](https://github.com/dbashford/mimosa-just-copy). Allows particular assets being watched by Mimosa to bypass being processed by other Mimosa modules, instead just being read and written.

### Major Changes
* Bumped node version required for Mimosa to 10.0+
* To prepare for [Bower](http://bower.io/) integration a `vendor` config has been added that indicates where vendor scripts and css are contained. Previously Mimosa had the concept of vendor assets, but there was no way to configure where those assets were. Mimosa treated anything with `/vendor/` in its path as being a vendor asset. So if you preferred to keep your vendor scripts someplace else, like, for instance, a `scripts` folder, then you missed out on the special treatment vendor scripts got (like having their own lint config or bypassing AMD scrutiny).

    ```javascript
    vendor:
      javascripts:"javascripts/vendor"
      stylesheets:"stylesheets/vendor"
    ```

### Minor Changes
* [mimosa #235](https://github.com/dbashford/mimosa/issues/235). mimosa-require will now recognize `//` as the beginning of a CDN path.  Previously it just recognized paths beginning with `http`.
* [mimosa #237](https://github.com/dbashford/mimosa/issues/237). `next` is now called in JS compiler if no files are in `options.files`.
* mimosa-testem-require. Updated default `specConvention` again to allow for tests to also end in either `-test.js` or `_test.js`.
* [mimosa-require #12](https://github.com/dbashford/mimosa-require/issues/12). mimosa-require will now log as an error when an alias path isn't used. So if a `backbone:'vendor/backbone'` alias exists, and you try to use `vendor/backbone` (which is not allowed), an error will be written.

### 0.14.0 Breaking Change

Details on possible breaking changes from the `vendor` config change:

* __Possibly no effect__ if you already have a file structure like that.
* __It may actually help__ if you don't keep your vendor assets in a `vendor` directory at all. Now you'll be able to let Mimosa know where they are and take advantage of vendor assets' special treatment.
* __It'll only cause you trouble if__ you had vendor assets in a `vendor` directory, but not right at the root of `javascripts` or `stylesheets`, you'll just need to add this config

## 0.13.18 - Jul 16 2013

### Minor Changes
* [mimosa #231](https://github.com/dbashford/mimosa/issues/231). Fixed bug with overwriting of RegExp properties in mimosa-config.
* mimosa. Bumped node-sass version.
* mimosa-require. Updated mimosa-require to expose its resolved depedency graph information for use by other modules.
* mimosa-testem-require. Updated default `specConvention` to allow for specs to end with either `_spec.js` OR `-spec.js`.  Previously it was just `_spec.js`.

## 0.13.17 - Jul 12 2013

### Minor Changes
* [mimosa #229](https://github.com/dbashford/mimosa/issues/229). Fixing windows install issues related to node-sass inclusion.

## 0.13.16 - Jul 12 2013

### Minor Changes
* mimosa. Updating to latest NPM to get around NPM bug

## 0.13.15 - Jul 12 2013

### Minor Changes
* [mimosa-require #11](https://github.com/dbashford/mimosa-require/issues/11). mimosa-require now has an `exclude` setting which allows you to have specific files opt out of processing by the module. Use this setting to not have specific files be verified or optimized. This doesn't prevent files from being optimized, but it prevents them from being registered as main optimization modules.

## 0.13.14 - Jul 11 2013

### Major Changes
* mimosa.  Iced CoffeeScript += Source Maps.

## 0.13.13 - Jul 11 2013

## New module
[mimosa-testem-require](https://github.com/dbashford/mimosa-testem-require). This module manages all your testing needs. It incorporates [Sinon](http://sinonjs.org/), [Chia](http://chaijs.com/), [Mocha](http://visionmedia.github.io/mocha/), [Testem](https://github.com/airportyh/testem) and [PhantomJS](http://phantomjs.org/) into a cohesive browser testing solution that reduces/removes the need to configure anything.  Simply put your spec files inside `watch.sourceDir` with a name that ends in `_spec` and testem-require will pick it up and execute it on startup or when JavaScript files are saved.

testem-require will also pull in your requirejs config and use it to resolve AMD paths. Complex requirejs configurations may require some additional module configuration, but in most cases you'll just include the module and start writing tests!

A demo app has been put together with the module included.  Go [clone the repo](https://github.com/dbashford/MimosaTestem) and check it out!

### Major Changes
* mimosa-testem-simple has had its cross-platform issues ironed out. It should function properly on Windows now. (Released as `v0.3.0` on July 04)
* [mimosa #227](https://github.com/dbashford/mimosa/issues/227). Mimosa now bundles [node-sass](https://github.com/andrew/node-sass). If you are using Ruby SASS and want a speed up, make the switch an give it a go! You cannot use Compass with node-sass and a little lag behind Ruby SASS is to be expected, but node-sass is a good deal faster. To enable node-sass add the following config:

```
sass:
  node:true
```

This setting is false by default to keep things backwards compatible.

### Minor Changes
* mimosa-combine.  Fixed encoding issue causing issues at tops of files being concatenated. (Released as `v0.8.2` on July 05)

## 0.13.12 - Jul 03 2013

### Minor Changes
* mimosa-require. Module now exports some requirejs configuration it has collected to be used by other modules.
* mimosa. `coffeescript.sourceMapExclude` has been updated: `[/\/specs?\//, /_spec.js$/]`
* mimosa-testem-simple. Updated testem to latest version.

## 0.13.11 - Jun 30 2013

### Minor Changes
* [mimosa #226](https://github.com/dbashford/mimosa/issues/226). No longer referencing localhost in the delivered `reload-client.js`, which solves problem with live reload not working when it is running elsewhere.

## 0.13.10 - Jun 29 2013

### Major Changes
* [mimosa #205](https://github.com/dbashford/mimosa/issues/205). `refresh` command has been removed.

## 0.13.9 - Jun 27 2013

### Minor Changes
* [mimosa #225](https://github.com/dbashford/mimosa/issues/225). Now recognizing amd/requirejs dependencies declared in `require`/`require.config` `deps` property.

## 0.13.8 - Jun 26 2013

### Minor Changes
* [mimosa #222](https://github.com/dbashford/mimosa/issues/222). Using new iced-coffee-script with proper semver-sioning.
* [mimosa-combine #9](https://github.com/dbashford/mimosa-combine/issues/9). Fixed bug with error being thrown for files inside directories. Released June 26.

## 0.13.7 - Jun 26 2013

### Minor Changes
* Dependent library updates

## 0.13.6 - Jun 25 2013

### Major Changes
* [mimosa #198](https://github.com/dbashford/mimosa/issues/198). `virgin` command has been removed.  New versions of `mimosa-client-jade-static` and `mimosa-require` released after removing `virgin` references.

### Minor Changes
* [mimosa-combine #7](https://github.com/dbashford/mimosa-combine/issues/7). Fixed bug causing ordered files to not be cleaned up.
* [mimosa-combine #8](https://github.com/dbashford/mimosa-combine/issues/8). Fixed bug causing empty directories as result of combine cleanup not being cleaned up.

## 0.13.5 - Jun 23 2013

Big changes/additions/fixes to the Stylus compiler with this release.

### Minor Changes
* [mimosa #224](https://github.com/dbashford/mimosa/issues/224). Better error message when cannot parse `.jshintrc` file
* [mimosa #221](https://github.com/dbashford/mimosa/issues/221). Mimosa now builds locally on Windows.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216), [mimosa #173](https://github.com/dbashford/mimosa/issues/173). Stylus `import` config is now available to be tweaked by the `stylus` root level config.  Previously the `import` config was automatically set to the same libraries as `use` was.  By default, the `import` config, an array, is set to `['nib']`.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216). Stylus `define` config available via the `stylus` root level config.
* [mimosa #216](https://github.com/dbashford/mimosa/issues/216). Stylus `include` config available via the `stylus` root level config.
* [mimosa #215](https://github.com/dbashford/mimosa/issues/215).  Fixed issue where `stylus.use` could not be set to an empty array.

## 0.13.4 - Jun 20 2013

### Minor Changes
* [mimosa #220](https://github.com/dbashford/mimosa/pull/220), [mimosa #218](https://github.com/dbashford/mimosa/issues/218). Adding back ansi-color require which got dropped this morning and was causing issues for folks who didn't have SASS installed.

## 0.13.3 - Jun 20 2013

### Major Changes
* mimosa. Mimosa now places modules into the config more easily allowing modules to use one another.

### Minor Changes
* mimosa-server-reload. Updated to refer to other modules via config.
* mimosa. Mimosa no longer freezes the configuration at any point.  Proved to be more trouble than it was worth.
* [mimosa #217](https://github.com/dbashford/mimosa/pull/217). Via PR added Travis, and using Mimosa to build withing having it installed.

## 0.13.2 - Jun 13 2013

### Major Changes
* mimosa/mimosa-minify. A bit of a toy feature, but the `mimosa-minify` module now supports two-step source maps with CoffeeScript.  CoffeeScript -> JavaScript -> minified/mangled JS, with source maps all the way back to the CoffeeScript.  Try it out!  In a CoffeeScript project run `mimosa watch -sm`, notice minified/mangled JS gets delivered to the client.  Break some CoffeeScript, go back to the browser, check the console and notice that the error points you back to the original line of CoffeeScript that caused the breakage.  Good stuff!
* [mimosa #214](https://github.com/dbashford/mimosa/pull/214), [mimosa #196](https://github.com/dbashford/mimosa/issues/196). PR to add [Coco](https://github.com/satyr/coco) support including assets for `mimosa new`.

### Minor Changes
* mimosa. Source map names now follow the `.js.map` convention.  Previously they were named simply `.map`

## 0.13.1 - Jun 10 2013

### Minor Changes
* mimosa. Fixing ECO scaffold templates

## 0.13.0 - Jun 10 2013

### Major Changes
* [mimosa #213](https://github.com/dbashford/mimosa/issues/213). Mimosa now comes with [ECO](https://github.com/sstephenson/eco) template compiling built in.  `mimosa new` also includes scaffolded ECO.
* [mimosa #187](https://github.com/dbashford/mimosa/issues/187). Mimosa is now compiled to JavaScript prior to being published to NPM. This should improve performance in a small way, but is also generally the right thing to do. The compiling of Mimosa pre-publish is performed by Mimosa.  Mimosa now has its own [mimosa-config](https://github.com/dbashford/mimosa/blob/master/mimosa-config.coffee). Mimosa has plenty of mostly CoffeeScript related lint errors that I'll be ironing out over time.

### Minor Changes
* [mimosa #212](https://github.com/dbashford/mimosa/pull/212). PR fixed issue with directories occasionally being deleted in the wrong order.  Generally effected only Windows but purely by circumstance. Theoretically should have effected all platforms.
* [mimosa #207](https://github.com/dbashford/mimosa/issues/207). Fixed validation issue with using Emblem along side other templating libraries.
* [mimosa #207](https://github.com/dbashford/mimosa/issues/207). Adjusted `mimosa-config` boilerplate comments for templates for correctness.
* mimosa. Upgraded jquery and requirejs libs in skeleton.
* mimosa. Fixed issue with Mimosa's hosted Express reporting a phantom 404 when refreshing the page.

## 0.12.6 - Jun 06 2013

### Major Changes
* [mimosa #201](https://github.com/dbashford/mimosa/issues/201), [mimosa #115](https://github.com/dbashford/mimosa/issues/115). IcedCoffeeScript boilerplate now pulled out into simple module that attaches `iced` to window. IcedCoffeeScript `runtime` compilation exposed via the `iced` config and defaults to `runtime:'none'`. You could choose, rather than going global with the `iced` object, to modify the `iced.js` library delivered with `mimosa new` to simply export `iced`, which would require you to pull in that module every time you need the async sugar IcedCoffeeScript provides.  The `mimosa new` boilerplate for IcedCoffeeScript projects shows how to use this.  But, with the `runtime` option opened up via the `iced` config, and the boilerplate code tossed into a file available via `mimosa new`, the power rests in the hands of the user to use the solution they feel is best.
* [mimosa #204](https://github.com/dbashford/mimosa/issues/204). Mimosa now allows for swapping out the version of Handlebars being used for compilation. This is useful for those building Ember apps who need versions of libraries to match. A new configuration parameter, `template.handlebars.lib`, takes the version of the handlebars compiler you'd like to use.  For example:

  ```
    template:
      handlebars:
        lib: require('handlebars')
  ```

  A project using this will need to have the desired version of Handlebars installed locally using npm.  For example: `npm install handlebars@1.0.11`.
* [mimosa #205](https://github.com/dbashford/mimosa/issues/205). Soon the `refresh` command will be removed. As of this release it has been deprecated. If you use it and rather it not go, please comment as such on this issue.

### Minor Changes
* [mimosa #202](https://github.com/dbashford/mimosa/issues/202), [mimosa #203](https://github.com/dbashford/mimosa/issues/203). Pull request fixing some CoffeeScript error reporting issues.
* mimosa. Various refactors and reorgs of codebase.

## 0.12.5 - Jun 1 2013

Back at it after a bit of a break.  Plenty to knock out in the coming weeks.

### Major Changes
* [mimosa #198](https://github.com/dbashford/mimosa/issues/198). Soon the `virgin` command will be removed. As of this release it has been deprecated. If you use it and rather it not go, please comment as such on this issue.
* [mimosa #191](https://github.com/dbashford/mimosa/issues/191). Mimosa now provides some flexibility in the naming of compiled templates. Previous to this release, templates would simply be named for the file they were in. So `foo.hbs` would be named `foo`. But certain frameworks, notably Ember, have conventions around the naming of templates that don't correspond with this, so a change we needed. A new property, `template.nameTransform` is now available for choosing how the template name is created. There are 4 possible settings.

    * (Default) `fileName`, this is the current name-of-file option. This being the default means this change is backwards compatible and won't cause any problems for folks upgrading.
    * `filePath`, this makes the name of the template the path of the file with 1) the `watch.javascriptDir` chopped off, 2) the slashes forced to `/`, and 3) the extension removed. No leading slash.
    * A RegExp can be provided.  That RegExp is applied on the `filePath` string from above to __remove__ any unwanted pieces of text from the string. The RegExp is used as part of a `string.replace`
    * A function can be provided.  That function is passed the `filePath` from above. The function must return a string that is the desired name of the template.

## 0.12.4 - May 15 2013

### Minor Changes
* mimosa. `mimosa mod:init [name] -c` now outputs a proper skeleton for a CoffeeScript based module, with all the necessary bits for using Mimosa to compile the module pre-install and publish.

## 0.12.3 - May 15 2013

### Minor Changes
* [mimosa #190](https://github.com/dbashford/mimosa/issues/190). Fixed issue with `mimosa refresh` and the previous release's `mimosa new` changes.

## 0.12.2 - May 14 2013

### Minor Changes
* mimosa. Included dust helpers in provided vendor dust file
* mimosa-require.  Bumped version of require.js to include the [newly introduced sourceMap support](http://jrburke.com/).
* Small reorg/refactor of some `mimosa new` code

## 0.12.1 - May 12 2013

### Minor Changes
* [mimosa #188](https://github.com/dbashford/mimosa/pull/188). Via pull request. `litcoffee` is now a default coffeescript extension and the coffeescript compiler will compile your Literate CoffeeScript files.
* [mimosa #186](https://github.com/dbashford/mimosa/issues/186). Can now run `mimosa mod:uninstall` without the name of the module if running command from inside the root directory of a module. So if inside `/yourMachine/modules/mimosa-foo`, running `mimosa mod:uninstall` will remove `mimosa-foo` from your Mimosa install.  This mimics the behavior of `mimosa mod:install`.
* [mimosa #184](https://github.com/dbashford/mimosa/issues/184). Fixing mimosa module creation problem.
* mimosa. Added the ability to have Mimosa exclude certain coffeescript files from sourcemap generation.  A new `sourceMapExclude` property was added that can be a regex or relative to `watch.javascriptDir`.  It defaults to `[/\/spec\//]`, which means it excludes source map generation for any files contained inside a `/spec/` directory or subdirectory.

## 0.12.0 - May 09 2013

Soon, probably with `0.13.0`, all Mimosa modules will need to be JavaScript.  They can be coded in any language you want, but they must be published to NPM as JavaScript modules.  Or, at the very least, the `main` piece of code referred to by the `package.json` [main](http://package.json.nodejitsu.com/), or the modules root level `index` file must be JavaScript.

All Mimosa modules that I have developed are written in CoffeeScript and compiled to JavaScript using Mimosa as part of the NPM workflow.  For an example Mimosa module written in CoffeeScript and built using Mimosa, check out the [require-commonjs](https://github.com/dbashford/mimosa-require-commonjs) code. You are welcome to publish modules as CoffeeScript as long as you manage that dependency.

__NOTE__ If you have trouble with your project after updating to `0.12.0`, specifically problems requiring Mimosa modules like `logmimosa`, do the following:

* Delete your `node_modules` directory
* Run `npm install` (if you have your own server)
* Start Mimosa

This should clear things up.

### Major Changes
* New module: [mimosa-testem-simple](https://github.com/dbashford/mimosa-testem-simple), includes `testem ci` integration.  Runs during `mimosa build` and for every JS file save during `mimosa watch`.
* All Mimosa modules are now compiled to JavaScript before publishing. Mimosa core is not, yet.
* All updated modules from previous bullet also had all their dependencies updated to the latest versions
* mimosa core has had all its libraries updated

### Minor Changes
* Upgraded dust and lodash client library to latest version
* Setting `template:null` is now a shortcut to turning off all template compilers.