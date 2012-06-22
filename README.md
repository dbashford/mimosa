mimosa - modern browser development toolkit
======

Mimosa is a catch-all browser development toolkit, targeted at folks using meta-languages like CoffeeScript and SASS, and using micro-templating libraries like Dust and Handlebars.  The toolkit is opinionated towards the use of [RequireJS](http://requirejs.org/) for dependency management.

Mimosa is not quite ready for prime-time (as of late June), still shaking things out, but feel free to play around.

## Features

 * Sane defaults allow you to get started with 0 configuration.  All you really need is an assets and a public directory.
 * Heavily configurable if moving away from defaults
 * Compiling of CoffeeScript + Iced CoffeeScript
 * Compiling of SASS (soon, LESS, Stylus)
 * Compiling of Handlebars and Dust
 * Compile assets when they are saved, not when they are requested
 * Growl notifications along with basic console logging.  If a compile fails, you'll know right away.
 * Automatic CoffeeLinting
 * Automatic JSHinting of compiled code
 * Basic Express skeleton building to put you on the ground running
 * Run in development with unminified/non-compressed javascript, turn on prod mode and run with a single javascript file using Require's optimizer
 * Live Reload built in, without the need for a plugin



#### Which meta-languages?

 Future additions are planned, but for now...

 * CSS: sass (default)
 * Micro-templating: handlebars (default), dust
 * JavaScript: coffeescript (default), iced coffeescript

## Installation

    $ npm install -g mimosa

## Quick Start

 The easiest way to get started with mimosa is to use the command line to
 create a new application skeleton. By default, mimosa will create a basic
 express app configured to match all of mimosa's defaults.

 First navigate to a directory within which you want to place your application.

 Create the default app:

    $ mimosa new -n nameOfApplicationHere

 Change into the directory that was created and execute:

    $ mimosa watch --server

 Mimosa will watch your assets directory and compile changes made to your public directory.

## Known major issues

 NODE_ENV=production can't be used straight away in a brand new project with uncompiled assets.  The require.js optimizer will choke.  Run it in dev mode first to get things compiled, then switch to production.  Fixing this will require a deeply necessary but chunky refactor.

## Roadmap

 I'll get to this stuff eventually!

 * Stylus, LESS compilers
 * Example templates beyond the one provided
 * Proper life cycle for compilation which should allow for easier plugging in of new steps/compilers, etc
 * Tests for the codebase
 * Integrated testing framework