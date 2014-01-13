exports.config =
  modules: ["jshint", "coffeescript", "copy"]
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  coffeescript:
    bare:true
  compilers:
    extensionOverrides:
      typescript: null
  copy:
    extensions: ["js", "ts", "json"]
  jshint:
    rules:
      node: true
      laxcomma: true