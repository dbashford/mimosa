exports.config =
  modules: ["jshint", "coffeescript@1.1.0", "copy"]
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  coffeescript:
    options:
      bare: true
      sourceMap: false
  compilers:
    extensionOverrides:
      typescript: null
  copy:
    extensions: ["js", "ts", "json"]
  jshint:
    rules:
      node: true
      laxcomma: true