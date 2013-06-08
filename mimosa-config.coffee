exports.config =
  modules: ["lint"]
  compilers:
    extensionOverrides:
      typescript: null
  watch:
    sourceDir: "src"
    compiledDir: "lib"
    javascriptDir: null
  copy:
    extensions: ["js", "ts"]
  lint:
    exclude:[/\/resources\//, /\/client\//]
    rules:
      javascript:
        node: true