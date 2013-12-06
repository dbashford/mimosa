exports.config =
  modules: ["jshint"]
  compilers:
    extensionOverrides:
      typescript: null
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  copy:
    extensions: ["js", "ts", "json"]
  jshint:
    exclude:[/\/resources\//, /\/client\//]
    rules:
      node: true