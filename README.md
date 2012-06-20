mimosa - build and serve web development meta-languages
======

 Not quite ready for prime-time, but feel free to play around.

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

 Mimosa will watch your assets directory and compile changes made to your public directory