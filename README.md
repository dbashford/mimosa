Mimosa - a modern browser development toolkit
======

Mimosa is a browser development toolkit, targeted at folks using meta-languages like (but not limited to) CoffeeScript or SASS, and micro-templating libraries like Jade, Handlebars and Underscore.  Mimosa is opinionated towards the use of [RequireJS](http://requirejs.org/) for dependency management and has a lot of support built around it.  Mimosa comes bundled with useful tools like js/css hint to improve code quality and live reload to speed up development.  Read through the entire [feature set](#features)!

And know there is more to come!  Mimosa is in full dev mode on its way to feature completeness, however, everything listed in this README should (mostly) work.

[Give it a whirl](#quick-start).  Please do [file issues](https://github.com/dbashford/mimosa/issues) should you find them, and don't hesitate to [request features](https://github.com/dbashford/mimosa/issues).  I haven't spent time testing Mimosa on Windows, so I wouldn't be surprised to learn it has issues.

## Features

 * Sane defaults allow you to get started without touching the configuration
 * Command line prompting during project creation to get you the configuration you want without having to comb through JSON and learn Mimosa's settings
 * A very simple (eventually less simple!) skeleton app build using the chosen meta-languages
 * Heavily configurable if moving away from defaults
 * Compiling of CoffeeScript + Iced CoffeeScript
 * Compiling of SASS (w/compass), LESS, and Stylus (w/nib)
 * Compiling of Handlebars, Dust, Hogan, Jade, Underscore, LoDash, and HTML templates into single template files to be used in the client
 * Compile assets when they are saved, not when they are requested
 * Growl notifications along with basic console logging, so if a compile fails, you'll know right away
 * Run in development with unminified/non-compressed javascript.  Turn on optimization and run with a single javascript file using RequireJS's optimizer and [Almond](https://github.com/jrburke/almond) with no need to configure the optimizer
 * Verify your RequireJS paths, catch circular dependencies and unwrapped modules in your application right away
 * Install dependencies like jquery or backbone into your project from GitHub via the command line
 * Automatic JSHinting, and CSSLinting
 * Basic Express skeleton to put you on the ground running with a new app, and a bundled Express for serving up assets to an existing app
 * Automatic static asset Gzip-ing, and cache busting
 * Live Reload built in, without the need for a plugin

### Why Mimosa?

What I wanted from Mimosa was a fast nothing-to-coding user-friendly experience.  Little-to-no mucking with config to get you started, no installing extra stuff yourself.  I want to deal with individual files during development, and let RequireJS handle optimized builds.  I want linting, gzip, live reload, and cache-busting all just there.  And I wanted real first-class support for RequireJS/AMD.

Much love and credit to [Brunch](http://brunch.io/) for the inspiration (hence 'Mimosa'), and for being the codebase I referenced when I had a problem to solve.  There's a lot here that Brunch does similarly, but also quite a bit I think Mimosa does differently.  I suggest you check Brunch out; it is awesome sauce.

Something missing from Mimosa for the short-term, that Brunch has in abundance, is a group of pre-built skeletons to get you started with things like Backbone and Bootstrap.  Those'll come after what I feel is the core feature set is complete and solid.

## Table Of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Command Line](#command-line)
	- [Help](#help)
	- [New Project (new)](#new-project-new)
		- [No Server (--noserver, -n)](#no-server---noserver--n)
		- [Pick the defaults (--defaults, -d)](#pick-the-defaults---defaults--d)
	- [Watch and Compile (watch)](#watch-and-compile-watch)
		- [Serve Assets (--server, -s)](#serve-assets---server--s)
		- [Serve Optimized Assets (--optimize, -o)](#serve-optimized-assets---optimize--o)
	- [Install Dependencies (install)](#install-dependencies-install)
		- [Non-AMD dependencies (--noamd, -n)](#non-amd-dependencies---noamd--n)
	- [Just Watch, Do Not Write (virgin)](#just-watch-do-not-write-virgin)
	- [One Time Asset Build (build)](#one-time-asset-build-build)
		- [Optimized Build (--optimize, -o)](#optimized-build---optimize--o)
		- [Compile the Provided Jade Template (--jade, -j)](#compile-the-provided-jade-template---jade--j)
	- [Clean Compiled Assets (clean)](#clean-compiled-assets-clean)
	- [Copy Config (config)](#copy-config-config)
	- [Update Install (update)](#update-install-update)
- [Meta-Language Compilation](#meta-language-compilation)
	- [JavaScript Meta-Languages](#javascript-meta-languages)
	- [CSS Meta-Languages](#css-meta-languages)
		- [SASS](#sass)
		- [LESS](#less)
		- [Stylus](#stylus)
	- [Micro-Templating Libraries](#micro-templating-libraries)
		- [Handlebars](#handlebars)
		- [Dust](#dust)
		- [Hogan](#hogan)
		- [Jade](#jade)
		- [Underscore](#underscore)
		- [LoDash](#lodash)
		- [HTML](#html)
- [Asset Copying](#asset-copying)
- [Optimize](#optimize)
	- [RequireJS support, JavaScript Optimization](#requirejs-support-javascript-optimization)
	- [CSS Minification](#css-minification)
- [Immediate Feedback](#immediate-feedback)
	- [Growl](#growl)
- [Linting Your JavaScript and CSS](#linting-your-javascript-and-css)
	- [Linting Compiled Assets](#linting-compiled-assets)
	- [Linting Copied Assets](#linting-copied-assets)
	- [Linting Vendor Assets](#linting-vendor-assets)
	- [Lint Rules](#lint-rules)
	- [JSHint, CSSLint](#jshint-csslint)
- [Live Reload](#live-reload)
- [GZip](#gzip)
- [Cache Busting](#cache-busting)
- [Roadmap](#roadmap)
- [Suggestions? Comments?](#suggestions-comments)

## Installation

As dev continues, I'll push to NPM whenever it makes sense.

    $ npm install -g mimosa

If you want the latest and greatest:

    $ git clone https://github.com/dbashford/mimosa.git
    $ cd mimosa
    $ npm install -g

## Quick Start

The easiest way to get started with Mimosa is to use it to create a new application skeleton. By default, Mimosa will create a basic Express app configured to match your desired meta-langauges.

First navigate to a directory within which you want to place your application. Create the default app:

    $ mimosa new nameOfApplicationHere

Follow the prompts and choose the meta-languages you'd like to use.

Change into the directory that was created and execute:

    $ mimosa watch --server

In your browser navigate to http://localhost:3000 to see the sample app.

Mimosa will watch your `assets` directory and compile changes made to your `public` directory.  It will also give you console and growl notifications for compilation results and code quality as files as saved.

To run the app in optimize mode, with all your JavaScript assets bundled into a single file, execute:

    $ mimosa watch --server --optimize

## Configuration

Mimosa's documentation is self-explanatory. The config file that comes bundled with the application contains all of the configurable options within the application and a brief explanation.  If you stick with the default options, like using CoffeeScript, Handlebars, and SASS, the configuration will be entirely commented out as the defaults are built into Mimosa.

To change something -- for instance to make it so you don't get notified via growl when your CSS meta-language (like SASS) compiles successfully -- uncomment the object structure that leads to the setting.  In this case you'd uncomment `growl.onSuccess.css`, and change the setting to `false`.

You can find the configuration [inside the skeleton directory](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).

## Command Line

One interacts with Mimosa via the command-line.

### Help

Mimosa includes extensive help documentation on the command line for each of the commands.  Give them a peek if you can't remember an option or can't remember what a command does.  Use `--help` or `-h` to bring up help. For example:

    $ mimosa --help
    $ mimosa new -h

### New Project (new)

The best way to get started with Mimosa is to use it to create a new application/project structure for you.  Create a new project like so:

    $ mimosa new nameOfApplicationHere

This will kick off a series of prompts that will allow you to pick out the meta-languages and templating library you'd like to use.  When you've finished picking, Mimosa will create a directory at your current location using the name provided as the name of the directory.  Inside that directory Mimosa will populate an application skeleton with public and asset directories, as well as the bare essentials for a base [Express](http://expressjs.com/) application.  You'll have Express [Jade template](http://jade-lang.com/) views, a simple Express [router](http://expressjs.com/guide.html#routing) and a server.coffee file that will be used by Mimosa to get Express [started](#serve-assets---server).

The public directory will be empty; it is the destination for your compiled JavaScript and CSS.  The assets directory has some example code -- chosen based on the selections you made via the prompts -- to get you started, and has a group of vendor scripts, like require.js.

The created directory will also contain the configuration file for Mimosa.  Almost everything inside of it is commented out, but all the options and explanations for each option are present.  The only things that will not be commented out will the javascript, css, and template compilers if you chose something other than the defaults.

#### No Server (--noserver, -n)

Should you not need all of the Express stuff, you can give Mimosa a `--noserver` flag when you create the project.  This will only give you the configuration file, the empty public directory, and the assets directory and all of its contents.

    $ mimosa new nameOfApplicationHere --noserver
    $ mimosa new nameOfApplicationHere -n

#### Pick the defaults (--defaults, -d)

Should you be happy with the defaults (CoffeeScript, Handlebars, and SASS) you can bypass the prompts by providing a `--defaults` flag.

    $ mimosa new nameOfApplicationHere --defaults
    $ mimosa new nameOfApplicationHere -d

### Watch and Compile (watch)

Mimosa will watch the configured `watch.sourceDir`, by default the assets directory.  When files are added, updated, or deleted, the configured compilers will perform necessary actions and keep the `watch.compiledDir` updated with compiled/copied assets.

 To start watching, execute:

    $ mimosa watch

When Mimosa starts up, it registers files in your `sourceDir` all at once.  If you have a very large number of files, 1000 images to copy over for instance, Mimosa may open enough files to cause EMFILE issues.  This means that Mimosa has opened up too many files at one time, more files than your system allows to be open at once.

To combat this, the `watch` config has a `throttle` property.  `throttle` is the number of files Mimosa should handle every 100 milliseconds during the initial Mimosa startup and for subsequent file additions.  For instance, if you set the number to 200, this means that if you have 1000 files, when Mimosa starts up it will process them in 5 chunks of 200, spaced 100 milliseconds apart.  It will do the same if, after Mimosa has started, you add 1000 files with a single copy or paste.

You may still run into EMFILE issues after setting throttle, and it might take some playing around with the number to get things just right.

The default for `throttle` is 0.  When `throttle` is set to 0, throttling is disabled and all files are processed immediately.

#### Serve Assets (--server, -s)

If you are not already running a server, and you need to serve your assets up, start Mimosa with the server flag.

    $ mimosa watch --server
    $ mimosa watch -s

By default, this will look for and run an Express app located at `server.path`.  If you used the Mimosa command line to build your new project, and you didn't provide the `--noserver` flag, you will have a server.coffee at the root of your file structure.  Mimosa will run the `startServer` method in this file.  You can leave this file as is if you are simply serving up assets, but this gives you the opportunity to build out an actual Express app should that be your desire.

You can change to using an embedded default (not-extendable) Express server by changing the `server.useDefaultServer` configuration to `true`.  If you created a project using the `--noserver` flag, this will have already been done for you.

#### Serve Optimized Assets (--optimize, -o)

Start Mimosa watching with the `--optimize` flag turned on and Mimosa will run RequireJS's optimizer on start-up and with every javascript file change.  So when you point at either the Express or default server's base URL with optimize flagged, you will be served the result of RequireJS's optimization, packaged with [Almond](https://github.com/jrburke/almond).

When `optimize` is turned on, Mimosa will also minify your CSS.

To start up with optimization turned on, execute the following:

    $ mimosa watch [--server] --optimize
    $ mimosa watch [--server] -o

### Install Dependencies (install)

    $ mimosa install [libraryName]

The `install` command will use [Volo](http://volojs.org/) to install dependencies for you.  Mimosa will first ask where you want to place the dependency, then it will use Volo to go fetch it from GitHub.  See the [Volo documentation](https://github.com/volojs/volo) for more details.

    $ mimosa install jquery

#### Non-AMD dependencies (--noamd, -n)

The only Volo option exposed by Mimosa at this time is the ability to turn on and off whether you are looking for an AMD or non-AMD version.  By default Mimosa will set the install to AMD.  But if you wish a non-AMD version of a library, provide a `-n` flag.

    $ mimosa install backbone --noamd

### Just Watch, Do Not Write (virgin)

Because, after all, a virgin mimosa is just orange juice.

    $ mimosa virgin

This command is just the watching, compiling, linting and notifications.  No server, no optimizations, no writing the output.  Use this if you've already got an application framework, you don't need files served, and you don't need optimizations.  But you do want to know if something doesn't compile before you reload the page, and you do want to introduce linting to your workflow.

### One Time Asset Build (build)

 If you just want to compile a set of assets, and you don't want to start up a watching process to do it, you can use Mimosa's build command.

    $ mimosa build

 This will run through your assets and compile any that need compiling, deliver the results to the public directory, and then exit.

#### Optimized Build (--optimize, -o)

If you want to build with optimization, provide a `--optimize` flag.  This will compile all the assets, create the requirejs optimized files, and minify your compiled CSS.

    $ mimosa build --optimize
    $ mimosa build -o

#### Remove Leftover Files (--removeCombined, -r)

When used in conjunction with `--optimize` the `--removeCombined` flag will clean up after the optimization.  If, when the optimization is complete, you only want the combined optimized files left behind, this is the flag for you.  This flag is a simple pass-through to the r.js compiler, which takes a `removeCombined` flag of its own.

This must be used with `--optimize` or Mimosa will error out.

    $ mimosa build --optimize --removeCombined
    $ mimose build -o -r

#### Compile the Provided Jade Template (--jade, -j)

Should you not be deploying a node/Express app, and you need an .html version of the `index.jade` that Mimosa provides with its `new` command, the `jade` flag will provide that.  The `jade` flag will attempt to compile the `index.jade` file by feeding the template production level settings.  `env` will be set to `production`.  `reload` set to `false`.  `optimize` will be set to `true` if you also provide the `optimize` flag.  `title` will be set to `Mimosa`.  It is suggested you remove the `title` variable and hard code your `title`.

If the `index.jade` file is changed to take different variables, or removed or renamed, the jade compilation will fail with warnings explaining the failures.

    $ mimosa build --jade
    $ mimosa build -j

### Clean Compiled Assets (clean)

A companion to build, this command will wipe out any files it is responsible for placing into the `compiledDir`.  It makes a pass to clean out the files, and once done, it makes a pass to clean out any directories that are now empty.  If for some reason there are files in your `compiledDir` directory structure that Mimosa didn't place there, they'll be left in place.

    $ mimosa clean

### Copy Config (config)

    $ mimosa config

If you've already got a project and want to use Mimosa with it, this command will copy the default configuration into whatever directory you are in.  You'll likely have some configuration to update to point Mimosa at your source and compiled directories.

### Update Install (update)

If you installed an application using the `new` command, you may want to keep your application up to date with the Mimosa skeleton as it evolves and advances.

Use the `install` command to update the node packages that Mimosa installed inside your application when it was created and to get any new libraries it has included.  This command saves you needing to update and keep current the packages installed at the outset.

For now Mimosa will not attempt to update any of the other assets it delivers (routes, example skeleton files, etc) because many of them may have significantly changed from when they were created.

Mimosa will first run `npm uninstall` for each of the skeleton libraries already in place in your project, and then it will follow up with an `npm install` on each removed library and each new library that wasn't there originally.

    $ mimosa update

### Debug Mode (-D, --debug)

All Mimosa commands have a debug mode that will print detailed logs to the console for everything Mimosa is doing.

    $ mimosa [command] --debug
    $ mimosa [command] -D

## Meta-Language Compilation

When Mimosa detects that a file change has occurred, Mimosa will compile your meta-languages and place the output in the public directory.

The meta-languages being used can be changed in the config.  The [default config file](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) contains a list of other options for each `compileWith`.

### JavaScript Meta-Languages

Mimosa will compile all of your CoffeeScript and Iced CoffeeScript files to JavaScript.

### CSS Meta-Languages

 Mimosa comes with three meta-languages that compile down to CSS   In all cases Mimosa keeps track of the 'base' files that require compilation, and will compile these base files when they change, or when one of their dependencies change.

 A base file is defined as a file that is imported by no other file.  Mimosa works under the assumption that if a file is imported, it does not need to be compiled individually, but the file doing the importing does.  So Mimosa follows your imports and compiles only those files that are at the root of the import tree.

 When the list of base files changes in some way post-startup, Mimosa lets you know via the console.

#### SASS

Mimosa will compile your [SASS](http://sass-lang.com/).  [Compass](http://compass-style.org/) can also be used with your SASS.

SASS and Compass are external Ruby dependencies that'll need to be installed outside of Mimosa.  See [here](http://sass-lang.com/) and [here](http://compass-style.org/install/) for install instructions.

#### LESS

Mimosa will compile your [LESS](http://lesscss.org/) files.

#### Stylus

Mimosa will compile your [Stylus](http://learnboost.github.com/stylus/) files and will include [nib](http://visionmedia.github.com/nib/) in the compilation, so all of nib's functionality is available to you.

### Micro-Templating Libraries

 Listed below are the six different micro-templating libraries Mimosa has built in.  As with the CSS and JavaScript meta-languages, the micro-templating libraries will be compiled when saved.  In all cases, the resulting compiled templates will be merged into a single file for use in the client.  Within that file will be @sourceUrl like information to allow you to easily track errors back to specific files in your codebase.

 The name and location of that single file is configurable (`compilers.template.outputFileName`), but by default it is kept at javascripts/template.  When this file is injected via require, the behavior differs per library, see below.

 For each templating langauge, the injected javascript file provides a JSON object of templates, keyed by the name of the the template originated in.

#### Handlebars

 [Handlebars](http://handlebarsjs.com/) is the default templating langauge.  To access a Handlebars template originating from a file named "example.hbs", do this...

 `var html = templates.example({})`

...passing in JSON data the template needs to render.

 Handlebars also provides the ability to code reusable helper methods in pure JavaScript.  You can code those in the meta-language of your choosing inside the `compilers.template.helperFiles` files.  The helpers and the templates are all pulled together via requirejs.

#### Dust

 To access a [Dust](https://github.com/linkedin/dustjs/) template originating from a file named "example.dust", do this...

 ```
 templates.render('example', {}, (err, html) -> $(element).append(html))
 ```

 You can reference dust partials, `{>example_partial/}`, and they will be available because all the templates are merged together.

#### Hogan

 To access a [Hogan](http://twitter.github.com/hogan.js/) template originating from a file named "example.hogan", do this...

 ```
 templates.example.render({name:'Hogan', css:'CSSHERE'}, templates)
 ```

 Note the passing of the templates object into the render method.  This isn't necessary, but if you use partials, it is all you'll need to do to make partials work since all partials are included in the compiled template file.

#### Jade

To access a [Jade](http://jade-lang.com/) template originating from a file named "example.jade", do this...

 `var html = templates.example({})`

#### Underscore

To access an [Underscore](http://underscorejs.org/) template originating from a file named "example.tpl", do this...

`var html = templates.example({})`

#### LoDash

To access a [LoDash](http://lodash.com/) template originating from a file named "example.lodash", do this...

`var html = templates.example({})`

#### HTML

If you just want to use plain HTML templates, you can do that too.

To access a plain HTML template originating from a file named "example.template", do this...

`var html = templates.example`

Full disclosure: Mimosa uses Underscore under the hood to handle getting your plain HTML templates to the browser as strings.  In this case, the Underscore compiler has been made so that it'll not understand it's usual delimiters for code or interpolation, and the resulting compiled Underscore templates are delivered as self-executing.  Will work on unhacking that in the future.

## Asset Copying

In the configuration there is a `copy.extensions` setting which lists the assets that will simply be moved over.  So, for example, images, plain ol' JavaScript (like vendor files, or should you choose code JavaScript), and regular CSS will be copied over.

If there are extra files you need copied over, uncomment the `copy.extensions` config and add it to the list.  Or, better yet, make a suggestion by [filing an issue](https://github.com/dbashford/mimosa/issues).  No harm in me growing the list of extensions in the default.

## Optimize

In the normal course of development, for debugging purposes, files should be loaded individually, rather than in one merged file, and you don't want your assets minified.  This all makes for easier debugging.

But when you take your application outside of development, you want to include all the performance improvements that come with merging, optimizing, and minifying your assets.  For both the `build` and `watch` commands, Mimosa provides an `--optimize` flag that will turn on this optimization.

Templates are merged together regardless, but they have source information included to make it easy to track back to the destination file, and templates will (ideally) be logic-less and less prone to problems.

### RequireJS support, JavaScript Optimization

Mimosa is loaded with AMD/RequireJS support.  Mimosa will..

 * Verify your module paths when your JavaScript meta-language (or JS itself) successfully compiles.  Mimosa will follow relative paths for dependencies, and also use your config paths whether they resolve to an actual dependency, ` jquery: 'vendor/jquery'`, or they resolve to a module, `moduleX:'a/path/to/module/x'`. Mimosa will also keep track of `map` settings and use them for path verification.  Path verification is enabled by default, but can be disabled by setting `require.verify.enabled` to false.
 * Alert you when paths are broken.  An unresolved path is as crucial as a compiler error; code is broken.  Should a path not be resolved, Mimosa will both write to the console and alert via Growl.
 * Catch when you have a circular dependency in your application and notify you on the console.
 * Catch when you have failed to wrap a non-vendor piece of compiled JavaScript in `require` or `define` and notify you on the console.
 * Run RequireJS' optimizer when the `optimize` flag is enabled for `mimosa build`, and on every file change for `mimosa watch`.
 * Need no config at all for the optimizer, which typically takes some time to configure.  Mimosa will keep track of your dependencies and build a vanilla optimizer configuration for you.
 * Handle multiple RequireJS modules just fine
 * Only compile those modules that need compiling based on the code that just changed
 * Bundle your optimized JavaScript with [Almond](https://github.com/jrburke/almond)

#### RequireJS Optimizer Defaults

Mimosa will infer some the following default settings for the built-in [r.js optimizer](https://github.com/jrburke/r.js/).

 * `baseUrl`: `baseUrl` is set by combining the `watch.compiledDir` with the `compilers.javascript.directory`.
 * `out`: The optimized files are output into the `watch.compiled` + `compilers.javascript.directory` in a file that is your main module + `-built.js`
 * `mainConfigFile`: set to the file path of the main module
 * `findNestedDependencies`: `true`
 * `wrap`: `true`
 * `include`: set to the name of the module being compiled
 * `insertRequire`: set to the name of the module being compiled
 * `name`: set to `almond`

These settings will package up each individual module you have into its own optimized file wrapped with Almond.

You can include any of the other RequireJS optimizer [configuration options](http://requirejs.org/docs/optimization.html#options) in the mimosa-config.  Simply uncomment the `require.optimize.overrides` setting and toss your settings in there.  You can both override and remove settings.  If you want to override a Mimosa setting, just put it in the `overrides`.  If you want a Mimosa default setting removed, set it to `null`.  For instance setting `mainConfigFile : null` will blank out that setting and it will not be passed to the optimizer.

You can also choose to not have Mimosa infer anything and to go entirely with your own configuration.  Set `require.optimize.inferConfig` to false and Mimosa will run r.js with the settings you give it

Also use `require.optimize.inferConfig:false` if you choose to have your configuration settings in script tags in an HTML file, or in any other file that does not compile to JavaScript.  For now, Mimosa is only able to make inferences for configs in JavaScript files.  If your configuration (and `require`/`requirejs` method calls) are in script tags on an HTML page, Mimosa will not find any modules to compile for optimization and therefore will not run optimization, so you'll need to provide your own configuration in `overrides` and set `inferConfig` to false

### CSS Minification

 When the `--optimize` flag is used, Mimosa will minify all of your compiled CSS files.

## Immediate Feedback

 Compilation of your assets is kicked off as soon as a file is saved.  Mimosa will write to the console the outcome of every compilation event.  Should compilation fail, the reason will be included in the log message.

### Growl

 If you have [Growl](http://growl.info/) installed and turned on, for each failure or successful compile of your meta-CSS/JS/Templates, you'll get a Growl notification.  In the event Growl gets too spammy for you, you can turn off Growl notifications for successful compiles.  Growl has its own setting in Mimosa, the defaults look like this:

```
# growl:
  # onStartup: false
  # onSuccess:
    # javascript: true
    # css: true
    # template: true
    # copy: true
```

If you [clean](#clean-compiled-assets-clean) your project and then start up the [watcher](watch-and-compile-watch), Mimosa will compile every asset you have.  If you have dozens or hundreds of assets, you may not want Growl notifications for each successful compile during this startup.  Startup success notifications are off by default.  You can turn on by uncommenting the config and setting the `growl.onStartup` flag to true.

You can also choose to turn off post-startup success notifications for compiled javascript, css, and templates, as well as for copied assets by altering the `growl.onSuccess` flats.  These notifications are on by default.

## Linting Your JavaScript and CSS

To 'lint' your code is to check it for common mistakes or variances from the idiom.  Mimosa will automatically lint all of the CSS and JavaScript it moves from your source directories to your compiled directories.  Any errors or warnings that come out of that linting will be printed to the console but will not stop or fail the compilation.  Inside the mimosa-config is this snippet which controls the linting.

```
# lint:
  # compiled:
    # javascript:true
    # css:true
  # copied:
    # javascript: true
    # css: true
  # vendor:
    # javascript: false
    # css: false
  # rules:
    # js:
      # plusplus: true
    # css:
      # floats: false
```

As with all of the default config, this is entirely commented out as the defaults are already enforced.

### Linting Compiled Assets

The `compiled` block controls whether or not linting is enabled for compiled code.  So if you've written SASS, LESS or Stylus, when Mimosa compiles it, Mimosa will send the resulting CSS through a linting process.  Similarly for the JavaScript meta-languages, Mimosa will lint the resulting JavaScript.

### Linting Copied Assets

If you've chosen to code js/css by hand, or if you've included a library written in js/css, the `copied` settings determine whether or not to lint those files.

### Linting Vendor Assets

Mimosa also allows you to control the linting of code contained in your `vendor` directory.  Linting is, by default, disabled for vendor assets, that is, those assets living inside a `/vendor/` directory.  Vendor libraries often break from the idiom, or use hacks, to solve complex browser issues for you.  For example, when run through CSSLint Bootstrap causes 400+ warnings.

If you want vendor asset hinting turned on, simply enable the setting and switch the flags to true.

### Lint Rules

The `rules` block is your opportunity to override and change the linting rules for each of the linting tools.  Example overrides are provided in the default configuration.  Those are examples, they are not actually overrides.

### JSHint, CSSLint

All of the lint/hinters come with default configurations that Mimosa uses.  Here are links to the tools, as well as to the configuration for those tools.

 * [JSHint](http://www.jshint.com/), [JSHint Config](http://www.jshint.com/options/)
 * [CSSLint](http://csslint.net/), [CSSLint Config](https://github.com/stubbornella/csslint/wiki/Rules)

## Live Reload

The default application you are provided comes built with live reload included.  Live Reload will immediately reload your web page any time an asset is compiled or one of your views changes.  So, for instance, if you change some LESS code, the instant it is compiled, and the compiled .css file is written to your `compiledDir`, your browser will update and your CSS updates will be displayed.

For those using the server code delivered to them via `mimosa new`, you have the ability to tweak how the reload works in the [`server.coffee`](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/server.coffee).  The library used for providing the Live Reload functionality is [watch-connect](https://github.com/Filirom1/watch-connect), and the github page has an explanation of the options you can pass in.  By default the reload will fire whenever the code in the `watch.compiledDir` changes, and whenever the code in the `view` directory of the application changes.  You have the ability to add more directories, and to exclude files from causing a reload using regexes.

To perform the Live Reload, the default application is built to include two extra libraries, including socket.io, to talk to the server and determine when to reload the page.  If you wish to turn this off, and thereby not include the two extra files, go into the mimosa-config.coffee file and update `server.useReload` to false.  These two extra files do not get wrapped up by RequireJS.

## GZip

 All your static assets will be served up GZip-ed!  'nuff said.

## Cache Busting

 No forcing a refresh to bypass caching issues.  All JavaScript and CSS files are cache-busted.

## Roadmap

  Many little bits and pieces, but the big ones are, in no certain order:

 * More require support: shim path verification, handle plugin depedencies, path fallbacks
 * More compilers across the board
 * example skeletons with things like Backbone/Chaplin/Angular/Ember, Bootstrap, etc
 * Tests for the Mimosa codebase
 * Integrated testing framework for your codebase

## Suggestions? Comments?

 @mimosajs

## License

(The MIT License)

Copyright (c) 2011 David Bashford

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.