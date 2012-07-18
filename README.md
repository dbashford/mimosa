Mimosa - a modern browser development toolkit
======

Mimosa is a browser development toolkit, targeted at folks using meta-languages like (but not limited to) CoffeeScript or SASS, and micro-templating libraries like Jade and Handlebars.  Mimosa is opinionated towards the use of [RequireJS](http://requirejs.org/) for dependency management, and comes bundled with useful tools like coffee/js/css hint to improve code quality and live reload to speed up development.  Read through the entire [feature set](#features)!

And know there is more to come!  Mimosa is in full dev mode on its way to feature completeness, however, everything listed in this README should work.

[Give it a whirl](#quick-start).  Please do [file issues](https://github.com/dbashford/mimosa/issues) should you find them, and don't hesitate to [request features](https://github.com/dbashford/mimosa/issues).  I haven't spent time testing Mimosa on Windows, so I wouldn't be surprised to learn there problems there.

- [Features](#features)
	- [Why Mimosa?](#why-mimosa)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Command Line Utilities](#command-line-utilities)
	- [Help](#help)
	- [New Project (new)](#new-project-new)
		- [No Server (--noserver)](#no-server---noserver)
		- [Pick the defaults (--defaults)](#pick-the-defaults---defaults)
	- [Watch and Compile (watch)](#watch-and-compile-watch)
		- [Serve Assets (--server)](#serve-assets---server)
		- [Serve Optimized Assets (--optimize)](#serve-optimized-assets---optimize)
	- [One Time Asset Build (build)](#one-time-asset-build-build)
		- [Optimized Build (--optimize)](#optimized-build---optimize)
	- [Clean Compiled Assets (clean)](#clean-compiled-assets-clean)
	- [Copy Config (config)](#copy-config-config)
- [Meta-Language Compilation](#meta-language-compilation)
	- [Which meta-languages?](#which-meta-languages)
- [Asset Copying](#asset-copying)
- [Micro-Templating Libraries](#micro-templating-libraries)
	- [Handlebars](#handlebars)
	- [Dust](#dust)
	- [Jade](#jade)
- [Immediate Feedback](#immediate-feedback)
	- [Growl](#growl)
- [Linting Your CoffeeScript, JavaScript and CSS](#linting-your-coffeescript-javascript-and-css)
	- [Linting Compiled Assets](#linting-compiled-assets)
	- [Linting Copied Assets](#linting-copied-assets)
	- [Linting Vendor Assets](#linting-vendor-assets)
	- [Lint Rules](#lint-rules)
	- [CoffeeLint, JSHint, CSSLint](#coffeelint-jshint-csslint)
- [RequireJS Optimization](#requirejs-optimization)
- [Live Reload](#live-reload)
- [GZip](#gzip)
- [Cache Busting](#cache-busting)
- [Roadmap](#roadmap)
- [Suggestions? Comments?](#suggestions-comments)


## Features

 * Sane defaults allow you to get started without configuring anything
 * Command line prompting during project creation to get you the configuration you want without having to comb through JSON and learn Mimosa's settings
 * A very simple (eventually less simple!) skeleton app build using the chosen meta-languages
 * Heavily configurable if moving away from defaults
 * Compiling of CoffeeScript + Iced CoffeeScript
 * Compiling of SASS (w/compass) + LESS (soon: Stylus)
 * Compiling of Handlebars, Dust and Jade templates into single template files to be used in the client (soon: Underscore, Hogan)
 * Compile assets when they are saved, not when they are requested
 * Growl notifications along with basic console logging, so if a compile fails, you'll know right away
 * Run in development with unminified/non-compressed javascript, turn on optimization and run with a single javascript file using RequireJS's optimizer and [Almond](https://github.com/jrburke/almond)
 * Automatic CoffeeLinting, JSHinting, and CSSLinting
 * Basic Express skeleton to put you on the ground running with a new app, and a bundled Express for serving up assets to an existing app
 * Automatic static asset Gzip-ing, and cache busting
 * Live Reload built in, without the need for a plugin

### Why Mimosa?

What I wanted from Mimosa was a fast nothing-to-coding user-friendly experience.  Little mucking with config to get you started, no installing extra stuff yourself.  I want to deal with individual files during development, and let RequireJS handle optimized builds.  I want linting, gzip, live reload, and cache-busting all just there.

Much love and credit to [Brunch](http://brunch.io/) for the inspiration (hence 'Mimosa'), and for being the codebase I referenced when I had a problem to solve.  There's a lot here that Brunch does similarly, but also quite a bit I think Mimosa does differently.  I suggest you check it out (as if you haven't already).  Brunch is awesome sauce.

Something missing from Mimosa for the short-term, that Brunch has in abundance, is a group of pre-built skeletons to get you started with things like Backbone and Bootstrap.  Those'll come after what I feel is the core feature set is complete and solid.

## Installation

As dev continues, I'll push to NPM whenever it makes sense.

    $ npm install -g mimosa

If you want the latest and greatest:

    $ git clone https://github.com/dbashford/mimosa.git
    $ cd mimosa
    $ npm install -g

## Quick Start

 The easiest way to get started with Mimosa is to create a new application skeleton. By default, Mimosa will create a basic Express app configured to match all of Mimosa's defaults.

 First navigate to a directory within which you want to place your application.

 Create the default app:

    $ mimosa new nameOfApplicationHere

 Follow the prompts and choose the meta-languages you'd like to use.

 Change into the directory that was created and execute:

    $ mimosa watch --server

 Mimosa will watch your assets directory and compile changes made to your public directory.  It will also give you console and growl notifications for compilation results and code quality as files as saved.

## Configuration

 Mimosa's documentation is self-explanatory. The config file that comes bundled with the application contains all of the configurable options within the application and a brief explanation.  If you stick with the default options, like using CoffeeScript, Handlebars, and SASS, the configuration will be entirely commented out as the defaults are built into Mimosa.

 To change something -- for instance to make it so you don't get notified via growl when your CSS meta-language (like SASS) compiles successfully -- uncomment the object structure that leads to the setting.  In this case you'd uncomment `growl.onSuccess.css`, and change the setting to `false`.

 You can find the configuration [inside the skeleton directory](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee).

## Command Line Utilities

 One interacts with Mimosa via the command-line.

### Help

 Mimosa includes extensive help documentation on the command line for each of the commands.  Give them a peek if you can't remember an option or can't remember what a command does.  For example:

    $ mimosa --help
    $ mimosa new --help

### New Project (new)

 The best way to get started with Mimosa is to use it to create a new application/project structure for you.  Create a new project like so:

    $ mimosa new nameOfApplicationHere

 This will kick off a series of prompts that will allow you to pick out the meta-languages and templating library you'd like to use.  When you've finished picking, Mimosa will create a directory at your current location using the name provided as the name of the directory.  Inside that directory Mimosa will populate an application skeleton with public and asset directories, as well as the bare essentials for a base [Express](http://expressjs.com/) application.  You'll have Express [Jade template](http://jade-lang.com/) views, a simple Express [router](http://expressjs.com/guide.html#routing) and a server.coffee file that will be used by Mimosa to get Express [started](#serve-assets---server).

 The public directory will be empty; it is the destination for your compiled JavaScript and CSS.  The assets directory has some example code -- chosen based on the selections you made via the prompts -- to get you started, and has a group of vendor scripts, like require.js.

 The created directory will also contain the configuration file for Mimosa.  Almost everything inside of it is commented out, but all the options and explanations for each option are present.  The only things that will not be commented out will the javascript, css, and template compilers if you chose something other than the defaults.

#### No Server (--noserver)

 Should you not need all of the Express stuff, you can give Mimosa a `--noserver` flag when you create the project.  This will only give you the configuration file, the empty public directory, and the assets directory and all of its contents.

    $ mimosa new nameOfApplicationHere --noserver

#### Pick the defaults (--defaults)

 Should you be happy with the defaults (CoffeeScript, Handlebars, and SASS) you can bypass the prompts by providing a --defaults flag.

    $ mimosa new nameOfApplicationHere --defaults

### Watch and Compile (watch)

 Mimosa will watch the configured `sourceDir`, by default the assets directory.  When files are added, updated, or deleted, the configured compilers will perform necessary actions and keep the `compiledDir` updated with compiled/copied assets.

 To start watching, execute:

    $ mimosa watch

#### Serve Assets (--server)

 If you are not already running a server, and you need to serve your assets up, start Mimosa with the server flag.

    $ mimosa watch --server

 By default, this will look for and run an Express app located at `server.path`.  If you used the Mimosa command line to build your new project, and you didn't provide the --noserver flag, you will have a server.coffee at the root of your file structure.  Mimosa will run the `startServer` method in this file.  You can leave this file as is if you are simply serving up assets, but this gives you the opportunity to build out an actual Express app should that be your desire.

 You can change to using an embedded default (not-extendable) Express server by changing the `server.useDefaultServer` configuration to `true`.  If you created a project using the --noserver flag, this will have already been done for you.

#### Serve Optimized Assets (--optimize)

 Start Mimosa watching with the --optimize flag turned on and Mimosa will run RequireJS's optimizer on start-up and with every javascript file change.  So when you point at either the Express or default server's base URL with optimize flagged, you will be served the result of RequireJS's optimization, packaged with [Almond](https://github.com/jrburke/almond).

 To start up with optimization turned on, execute the following:

    $ mimosa watch [--server] --optimize

### One Time Asset Build (build)

 If you just want to compile a set of assets, and you don't want to start up a watching process to do it, you can use Mimosa's build command.

    $ mimosa build

 This will run through your assets and compile any that need compiling, deliver the results to the public directory, and then exit.

#### Optimized Build (--optimize)

 If you want to build with optimization, provide a --optimize flag.  This will compile all the assets, and then create the requirejs optimized files for use in production.

    $ mimosa build --optimize

### Clean Compiled Assets (clean)

 A companion to build, this command will wipe out any files it is responsible for placing into the `compiledDir`.  It makes a pass to clean out the files, and once done, it makes a pass to clean out any directories that are now empty.  If for some reason there are files in your `compiledDir` directory structure that Mimosa didn't place there, they'll be left in place.

    $ mimosa clean

### Copy Config (config)

    $ mimosa config

 If you've already got a project and want to use Mimosa with it, this command will copy the default configuration into whatever directory you are in.  You'll likely have some configuration to update to point Mimosa at your source and compiled directories.

## Meta-Language Compilation

 Mimosa will compile your meta-languages for you and place the output in your public directory.

 You can change your meta-languages in the config.  The [default config file](https://github.com/dbashford/mimosa/blob/master/lib/skeleton/mimosa-config.coffee) contains a list of other options for each `compileWith`.

### Which meta-languages?

 Future additions are planned, but for now...

 * CSS: SASS (default), LESS
 * Micro-templating: Handlebars (default), Dust, Jade
 * JavaScript: CoffeeScript (default), Iced CoffeeScript

## Asset Copying

 In the configuration there is a `copy.extensions` setting which lists the assets that will simply be moved over.  So, for example, your images, plain ol' JavaScript (like vendor files, or should you choose code JavaScript), and regular CSS will be copied over.

 If there are extra files you need copied over, uncomment the `copy.extensions` config and add it to the list.  Or, better yet, make a suggestion by [filing an issue](https://github.com/dbashford/mimosa/issues).  No harm in me growing the list of extensions in the default.

## Micro-Templating Libraries

 Mimosa comes bundled with three different micro-templating languages for to pick from for client rendering.  [Dust](https://github.com/linkedin/dustjs), [Handlebars](http://handlebarsjs.com/), and [Jade](http://jade-lang.com/).  As with the CSS and JavaScript meta-languages, the micro-templating libraries will be compiled when saved.  In all cases, the resulting compiled templates will be merged into a single file for use in the client.

 The name and location of that single file is configurable (`compilers.template.outputFileName`), but by default it is kept at javascripts/template.  When this file is injected via require, the behavior differs per library.

### Handlebars

 Handlebars is the default templating langauge.  The injected template javascript file provides a JSON object of templates.  To access, for instance, a template originating from a file named "example.hbs", you would do this...

 `var html = templates.example({})`

...passing in JSON data the template needs to render.

 Handlebars also provides the ability to code reusable helper methods in pure JavaScript.  You can code those in the meta-language of your choosing inside the `compilers.template.helperFiles` files.  The helpers and the templates are all pulled together via requirejs.

### Dust

 Dust is also available as a template language.  The injected template javascript file provides a JSON object of templates.  To access, for instance, a template originating from a file named "example.dust", you would do this...

 ```
 templates.render('example', {}, (err, html) -> $(element).append(html))
 ```

### Jade

 Jade is a third available template language.  The injected template javascript file provides a JSON object of templates.  To access, for instance, a template originating from a file named "example.dust", you would do this...

 `var html = templates.example({})`

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

## Linting Your CoffeeScript, JavaScript and CSS

Linting is a code checking process that finds common mistakes in your code, or just variances away from the idiom.  Mimosa can automatically lint all of the CSS and JavaScript it moves from your source directories to your compiled directories.  Any errors or warnings that come out of that linting will be printed to the console.  Inside the mimosa-config is this snippet which controls the linting.

```
# lint:
  # compiled:
    # coffee:true
    # javascript:true
    # css:true
  # copied:
    # javascript: true
    # css: true
  # vendor:
    # javascript: false
    # css: false
  # rules:
    # coffee:
      # max_line_length:
      #   value: 80,
      #   level: "error"
    # js:
      # plusplus: true
    # css:
      # floats: false
```

As with all of the default config, this is entirely commented out as the defaults are already enforced.

### Linting Compiled Assets

The `compiled` block controls whether or not linting is enabled for compiled code.  So if you've written SASS, when Mimosa compiles it, Mimosa will send the resulting CSS through a linting process.  For CoffeeScript, Mimosa will both lint your CoffeeScript code before it compiles it to JavaScript, and then lint your resulting JavaScript too.

### Linting Copied Assets

If you've chosen to code js/css by hand, or if you've included a library written in js/css, the `copied` settings determine whether or not to lint those files.

### Linting Vendor Assets

Mimosa also allows you to control the linting of code contained in your `vendor` directory.  Linting is, by default, disabled for vendor assets, that is, those assets living inside a `/vendor/` directory.  Vendor libraries often break from the idiom, or use hacks, to solve complex browser issues for you.  For example, when run through CSSLint Bootstrap causes 400+ warnings.

If you want vendor asset hinting turned on, simply enable the setting and switch the flags to true.

### Lint Rules

The `rules` block is your opportunity to override and change the linting rules for each of the linting tools.  Example overrides are provided in the default configuration.  Those are examples, they are not actually overrides.

### CoffeeLint, JSHint, CSSLint

All of the lint/hinters come with default configurations that Mimosa uses.  Here are links to the tools, as well as to the configuration for those tools.

 * [CoffeeLint](http://www.coffeelint.org/), [CoffeeLint Config](http://www.coffeelint.org/#options)
 * [JSHint](http://www.jshint.com/), [JSHint Config](http://www.jshint.com/options/)
 * [CSSLint](http://csslint.net/), [CSSLint Config](https://github.com/stubbornella/csslint/wiki/Rules)

## RequireJS Optimization

 Both of the following mimosa commands will involve [RequireJS optimization](http://requirejs.org/docs/optimization.html):

    $ mimosa watch [--server] --optimize
    $ mimosa build --optimize

 By default, Mimosa will use main.js in the public directory as the sole module to be optimized, but this can be changed in the mimosa-config by tweaking the `require.name` setting.  The output will be placed in the root of the public directory, in main-built.js, and this too can be changed by changing `require.out`  The only other default setting is a path/alias set up pointing at jquery in the vendor directory.  You can add other paths/aliases along side the jquery one, remove the jquery path or point it someplace else.

 The RequireJS optimizer has many [configuration options](http://requirejs.org/docs/optimization.html#options).  Any of these options can be added directly to the `require` setting and Mimosa will include them in the optimization.

## Live Reload

  The default application you are provided comes built with live reload included.  Live Reload will immediately reload your web page any time an asset is compiled.  So, for instance, if you change some LESS code, the instant it is compiled, and the compiled .css file is written to your `compiledDir`, your browser will update and your CSS updates will be displayed.

  To do this, the default application is built to include two extra libraries, including socket.io, to talk to the server and determine when to reload the page.  If you wish to turn this off, and thereby not include the two extra files, go into the mimosa-config.coffee file and update `server.useReload` to false.  These two extra files do not get wrapped up by RequireJS.

## GZip

 All your static assets will be served up GZip-ed!  'nuff said.

## Cache Busting

 No forcing a refresh to bypass caching issues.  All JavaScript and CSS files are cache-busted.

## Roadmap

  In no certain order:

 * More compilers across the board
 * example skeletons with things like Backbone/Chaplin/Angular/Ember, Bootstrap, etc
 * Push to NPM
 * Tests for the Mimosa codebase
 * Integrated testing framework for your codebase
 * Other server options

## Suggestions? Comments?

 @mimosajs


