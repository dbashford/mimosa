## 1.0.0-rc.3 - Sept 03 2013

### Huge Changes
* [mimosa-require #14](https://github.com/dbashford/mimosa-require/issues/14). Mimosa needed to have all of its JavaScript rebuilt with every startup so that mimosa-require could rebuild its dependency graph. With this release, mimosa-require is capable of tracking your project's dependency information between Mimosa runs. mimosa-require will persist to the file system the information it needs to startup without requiring all JavaScript files to be processed/compiled. A new `tracking` configuration has been added to the `require` config. When `require.tracking.enabled` is set to `true`, mimosa-require will keep track of dependency information on the file system.

  `require.tracking.enabled` defaults to `false` for now while this feature is new and still being worked out. It will default to `true` in the near future after its had some time to shake out.

  If files are moved or changed while Mimosa is not running, `tracking` may get out of sync. When this happens, run a `mimosa clean` and mimosa-require will rebuild its tracking information.

### Major Changes
* __New Module__: [mimosa-coffeelint](https://github.com/dbashford/mimosa-coffeelint) allows you to lint your coffeescript.
* [mimosa #273](https://github.com/dbashford/mimosa/issues/273). By default Mimosa now outputs source maps as dynamic. So no `.map` or `.src` files are written, instead the map and source are base64 encoded and placed inside the JavaScript output. This means 66% less CoffeeScript related I/O and 66% fewer HTTP requests. Fewer HTTP requests also means less clutter in your debugger. Dynamic source maps also allow for tools like browserify to utilize the source maps as part of bundling.

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

## 0.11.12 - May 03 2013

### Minor Changes
* mimosa. Small refactors and fixes to module loading.
* mimosa. [mimosa #177](https://github.com/dbashford/mimosa/pull/177).  Got a pull request that allows you to code up your mimosa-config in whichever language you want, whether mimosa supports it or not.  Details in the pull request.
* [mimosa-web-package #4](https://github.com/dbashford/mimosa-web-package/issues/6). Added a new `appjs` option to `web-package`.  When set to `null`, Mimosa will not write the `app.js` application bootstrapper.  When set to a string, the string is the name `web-package` will use when writing the file.  So `appjs:"foo.js"` will write a `foo.js` file.  This setting defaults to `app.js`.
* mimosa-web-package is now compiled to JavaScript with Mimosa prior to being published to NPM.

## 0.11.11 - April 25 2013

### Minor Changes
* [mimosa #175](https://github.com/dbashford/mimosa/issues/175).  Fixed node v0.10 related issue with creating new project without a project name.
* mimosa. Updated SASS compiler to find imports that do not start with `_`.

## 0.11.10 - April 24 2013

### Minor Changes
* [mimosa #173](https://github.com/dbashford/mimosa/issues/173). You can now use external stylus libraries during compilation of Stylus files without pulling in all the source for those libraries.  A new Stylus configuration was added:

  ```
    stylus:
      use:['nib']
  ```

  Add to the `use` array those libraries you have locally `npm install`ed and want to use with Stylus.  Mimosa will get snippy with you if you try to use something that isn't installed. =)

## 0.11.9 - April 23 2013

### Major Changes
* mimosa-lint. mimosa-lint is now compiled to JavaScript prior to being published to NPM so that the delivered module is in the target language. This is the beginning of using Mimosa to compile Mimosa. I'll be cycling through all the Mimosa modules performing this change before eventually doing it with Mimosa core.
* mimosa-lint. Upgraded to latest jshint version.

### Minor Changes
* mimosa. `watch.javascriptDir` can be made `null`.  This allows for building apps that aren't strictly web apps.  Mimosa modules, for instance.
* [mimosa-web-package #4](https://github.com/dbashford/mimosa-web-package/issues/4). `web-package` will no longer write an `app.js` or execute an `npm install` if the packaged application uses the default server. (published as `web-package` version `0.10.0` on 4/18)

## 0.11.8 - April 17 2013

### Minor Changes
* [mimosa #171](https://github.com/dbashford/mimosa/issues/171). If using node 0.10 and starting mimosa in a directory with no mimosa-config, the output was a stack trace.  Now it should be a useful validation error message.
* [mimosa #172](https://github.com/dbashford/mimosa/issues/172). On Windows, `npm install` requires a `node_modules` in the current directory or else it installs the package elsewhere. So creating empty `node_modules` when needed.

## 0.11.7 - April 11 2013

### Minor Changes
* [mimosa #170](https://github.com/dbashford/mimosa/issues/170). Fixed issue with live reload crashing mimosa on node v10 + windows 8.

## 0.11.6 - April 10 2013

### Minor Changes
* [mimosa #168](https://github.com/dbashford/mimosa/issues/168). Added `md` as a default copy extension.
* [mimosa #169](https://github.com/dbashford/mimosa/issues/169). Fixing CoffeeScript compile error messages. Adding line numbers.
* [mimosa-web-package #2](https://github.com/dbashford/mimosa-web-package/issues/2). Config paths generated by `mimosa-web-package` are now target environment agnostic. Previously the paths matched the build environment.  So if you were building on Windows and deploying to *nix, there would be path work to do.  Now that is not a problem as the paths are calculated in the `config.js` that `mimosa-web-package` generates.

## 0.11.5 - April 08 2013

Doing some Heroku work, so making some changes to both Mimosa and mimosa-web-package to accommodate some Heroku learnings.

### Minor Changes
* Cleanup from previous TypeScript release
* mimosa-web-package. Added `.gitignore` to the list of files not packaged.
* mimosa-web-package. The output `config.json` which was a partially resolved `mimosa-config`, is now `config.js` as it contains some code. That code helps properly point the packaged web app at the location of the compiled assets. For instance, Heroku isn't happy with "public", it needs to be pointed at `path.join(__dirname, "public")`.
* mimosa. Modified `mimosa new` delivered servers to set port in a way that makes Heroku happy.
* [mimosa #165](https://github.com/dbashford/mimosa/issues/165). Fixed issue with Mimosa new erroring out.

### Breaking Changes
* Only possible breaking changes are minor and with `web-package`, and in most cases shouldn't be breaking at all.  Previously the `web-package` config file was output as `config.json`, now it is `config.js` as it contains some code to resolve the location of static assets properly.

## 0.11.4 - April 07 2013

### Major Changes
* Got a great pull request that upgraded TypeScript support to `0.8.3.0` and fixed some other TypeScript issues.

## 0.11.3 - April 04 2013

Purely a `mimosa-require` related release. Enhanced requirejs/r.js support in many ways.

### Major Changes
* [mimosa-require #9](https://github.com/dbashford/mimosa-require/issues/9) - Mimosa's requirejs support now includes recognition of common configuration. Now for multi-page applications, you can create a single requirejs configuration that gets referenced by your main modules. This support extends to the use of `r.js` and to Mimosa's requirejs path validation.

  By default, Mimosa will look in `javascripts/common.js` for common config. For a good example of how a common require config works, check out the [the requirejs example](https://github.com/requirejs/example-multipage/tree/master/www/js) for that sort of project.  Pay special attention to the `common.js` file and how it is included and used in `page1/2.js`

### Minor Changes
* mimosa-require. Added detection of `require` calls embedded within the callbacks of other `require` calls.  Previous only `define` callbacks were scanned for `require` calls.
* mimosa-require. Added detection of `require` calls that take arrays of dependencies that are embedded within other `define`/`require` callbacks. Previously only single string `require` calls (i.e. `require('foo')`) were detected.  Now requires with arrays and callbacks are detected.  i.e. `require(['foo', 'bar'], function(){})`
* mimosa-require. Fixed issue with path validations caching references to aliased directories.

## 0.11.2 - March 28 2013

Various lib updates.

### Minor Changes
* Upgraded the `require.js` and `jquery.js` delivered with `mimosa new`
* Upgraded the `package.json` delivered with `mimosa new`
* `mimosa new` will now output the `npm install` output on successful install.
* Mimosa's auto-install of Mimosa modules on startup will now output the `npm install` output on successful install.
* npm updated to latest

## 0.11.1 - March 24 2013

### Minor Changes
* [mimosa-server #3](https://github.com/dbashford/mimosa-server/issues/3) - When not using the default server (when project has its own server), the config setting `server.views.path` is relative to `server.path` instead of relative to the root of the project. When using the default server `server.views.path` remains relative to the root of the project. The `server.views.path` is passed to the project's server.

### Possible Breaking Changes
* If you've got your own server and have configured specific (non-default) paths for `server.views.path` and `server.path`, you may need to tweak the `server.views.path`.

## 0.11.0 - March 21 2013

Source maps! Part of the changes for adding source maps opened up being able to configure the coffeescript compiler from the `mimosa-config`, so defaulting `bare` compilation to `true`, which has been a rainy day thing I've wanted to do for awhile, became possible. That might break some applications that aren't wrapping code (if you aren't using AMD or CommonJS via AMD), hence the uptick to `0.11.0`. See the Breaking Changes section below.

### Major Changes
* mimosa #163. CoffeeScript and Iced CoffeeScript files will now compile `bare` by default. The assumption is that with Mimosa being opinionated towards the use of AMD or AMD wrapping of CommonJS modules, all code ought to be wrapped anyway. This can be set back with config. See the config snippet below.
* mimosa #161. CoffeeScript [source maps](http://www.html5rocks.com/en/tutorials/developertools/sourcemaps/) ftw. Source maps are enabled by default for CoffeeScript files for `mimosa watch`.  A new `coffeescript` root level config allows for turning source maps off. Source maps are turned off during `mimosa build`. If you've not used source maps before, I highly encourage trying them out. Quickly fire up a new Mimosa project, `mimosa new foo -d`, and break some CoffeeScript. Then point at the project with Chrome developer tools on and bear witness to the source map goodness.

  ```coffeescript
    coffeescript:
      sourceMap:true
      bare:true
    iced:
      bare:true
  ```

### Minor Changes
* mimosa #162. Added `map` to the list of default copy extensions.

### Possible Breaking Changes
* With `bare` now set to `true` by default (was previously `false`), you'll want to check your Coffee/Iced apps to make sure things still work alright. If they don't simply flip the setting back to `false` or address why unwrapped code and scope bleed might be causing trouble.

## 0.10.6 - March 16 2013

### Minor Changes
* mimosa #160.  Log error if `mimosa new` `npm install` fails.

## 0.10.5 - March 16 2013

### Minor Changes
* mimosa #159.  First and hopefully last node `v0.10.0` bug fix.

## 0.10.4 - March 15 2013

### Major Changes
* mimosa #146.  First new module in awhile.  [mimosa-client-jade-static](https://github.com/dbashford/mimosa-client-jade-static) will take files that end in `.html.jade`, static jade templates, compile them, execute them, and write them as individual `.html` files. These jade templates cannot be dynamic in any way. The (initial) target use case is to have small template files to pull in using RequireJSs `text` plugin.
* mimosa #138.  New mimosa-combine version defaults to removing the files that go into the combined file during `mimosa build` (not during `mimosa watch`).  This deprecates the old config.  For one minor version mimosa-combine will support both the old and new configs for mimosa-combine and will warn you when Mimosa starts to give you the change to make the necessary changes.  The deprecated config option will be removed the next time mimosa-combine has a significant release.  See the [mimosa-combine github](https://github.com/dbashford/mimosa-combine) for config details.
* mimosa-require #10. Default support for requirejs source maps has been added. When `mimosa watch` is used with `--optimize` (and not also `--minify` which does minification outside of requirejs), Mimosa will generate source maps for easy debugging in browser dev tools. `mimosa build` does not generate source maps. All cleans performed by various Mimosa tasks will clean up the generated `.src` and `.map` files.  Because generation of source maps is configured via the r.js config, which can already be overridden in the `require` config, no additional config settings have been added to change the default behaviors.

### Minor Changes
* mimosa #157. Fixed issue with css pre-compilers thinking directories were files.
* mimosa #155. Fixed issue with new `mimosa-client-jade-static` module that wasn't letting modules update/delete after startup.
* mimosa #154. Non JS will not get sent through require path verification, not a problem previously but will be a problem with any modules that turn what is typically a fully JS workflow (like template compiling) into a mixed workflow (like when jade templates are compiled to static HTML on the server as with mimosa-client-static-jade)
* mimosa #152. Extension-to-compiler matching is now case-insensitive. So as far as Mimosa is concerned, PNG == png, and so on.
* mimosa #150. Improved default server error messaging when a view is not found.
* mimosa-require. Removed dependency on uglify.
* mimosa-require. `uglify2` is now the default Uglifier for RequireJS. If needed this can be changed back to `uglify` by overriding the optimizer settings in the `require` config.
* mimosa-server-reload #3, improved error messaging for module not being in the same module space as other mimosa modules it depends on.

## 0.10.3 - March 3 2013

### Major Changes
* Fixes #147, with the help of the Emblem author, refactored the Mimosa Emblem compiler to not depend on jsdom, which introduces some cross-platform issues.
* Upgraded to the latest Emblem which also removes a Mimosa dependency on git introduced in the last release.

## 0.10.2 - Feb 25 2013

### Major Changes
* Auto-installed modules, those discovered in the `modules` array but not discovered installed in any of Mimosa's module scopes, will now install into the project scope. This should alleviate permissions issues with installing modules into Mimosa which is often installed in a global protected scope.

## 0.10.1 - Feb 25 2013

### Major Changes
* mimosa #145, added [Emblem](http://emblemjs.com/) compiler. Emblem is wicked cool. Despite resembling jade/haml,it parses to [Handlebars](http://handlebarsjs.com/) [AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree) which can then be passed to Handlebars for precompilation. The output of precompilation is the same as the output for pure Handlebars precompilation. This is awesome for folks that need to use Handlebars (Ember.js) but prefer a terser syntax.

  The existing `template.handlebars` config is used by the Emblem compiler.  The Emblem compiler can output Ember compliant code by enabling ember the same way as with handlebars. So the snippet below from the `0.10.0` release applies to Emblem.  See the [Mimosa Ember Emblem project on github](https://github.com/dbashford/mimosa-ember-emblem-templates) for an example of this running.

## 0.10.0 - Feb 23 2013

Jumping up to `0.10.0` as there are a few breaking changes, so check out the "You'll need to..." section below.

Updates to how templating is handled has been a theme, and this release continues that. Added Ember.Handlebars and the ability to skip the AMD wrapping of compiled templates. Also added more robust routing capabilities to the default server.

### Major Changes
* mimosa #135, Mimosa's handlebars template compiler will now compile Ember.js templates. To enable Ember compiling, inside the `template.handlebars` config, place an `ember` object like so:

  ```
    template:
      handlebars:
        ember:
          enabled:true
          path:"vendor/ember"
  ```

  The `enabled` flag turns on Ember compiling, and the path string is the AMD location of the Ember library, which is built into the AMD wrapper for the compiled templates.
* mimosa #140, Mimosa's template compilers will now allow combined/merged template file compilation without the AMD wrapper.  A new property `amdWrap` has been added to the `template` config.  It defaults to `true`.  When set to `false`, Mimosa will not AMD wrap the compiled template files.
* mimosa #144, Mimosa's default server got a bit of an overhaul.  The `server.useDefaultServer` property is now `server.defaultServer.enabled` to make way for more `defaultServer` config.  Added to `defaultServer` is a `onePager` boolean that defaults to `false`. When set to `true` Mimosa will route all traffic through the `index` view. This allows for complex URLs like `url:3000/user/steve` to route to the `index` view and then be handled by client routing code. When `onePager` is set to `false`, Mimosa will route all traffic to assumed view names. `url:3000/` will go to `index` as expected, but now `url:3000/foo` will go to `foo` and so on.

### Minor Changes
* mimosa, fixed template name collision issue
* If a project scoped Mimosa module errors out upon requiring, Mimosa now exits.
* mimosa #133, complex folder structures for stylesheets no longer causing issues with proper stylesheets being compiled
* mimosa #137, handling file extensions properly in mimosa-require for dependencies aliased by directory
* mimosa #142, moved `helperFiles:[]` into `handlebars:helpers:[]` to make way for more template specific config.
* mimosa #143, update client and server handlebars to latest version
* mimosa-web-package, with `0.9.0` Mimosa modules can be in a project's package.json. Now Mimosa module dependencies are removed from the package.json before it is written into the `dist` directory.
* mimosa-require-commonjs #2, fixed issue with empty output from .d.ts files
* mimosa-require-commonjs #3, fixed issue with excludes not working properly

### You'll need to...
* If you were using the `helperFiles` config, you'll need to change that config around.  `helperFiles:[]` should now look like this:

  ```coffeescript
    handlebars:
      helpers:[]
  ```

* `server.useDefaultServer` is now `server.defaultServer.enabled`.  Also added is a `server.defaultServer.onePager` boolean which defaults to `false`. If you were relying on Mimosa's default server to route all paths through the index page, then you will want to set `onePager` to `true`. The default for this was essentially `true` prior to this release.

  ```coffeescript
    server:
      defaultServer:
        enabled: true
        onePager: true
  ```