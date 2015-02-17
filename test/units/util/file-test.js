var path = require( "path" )
  , fileUtil = require( path.join(process.cwd(), "lib", "util", "file") )
  ;

describe("Mimosa file utility's", function() {

  describe("remove .mimosa function", function() {
    it("will remove .mimosa from the cwd");
    it("will not error out if .mimosa is missing");
  });

  describe("isCSS function", function(){
    it("will properly recognize a CSS file");
    it("will properly recognize when a file is not CSS");
  });

  describe("isCSS function", function(){
    it("will properly recognize a CSS file");
    it("will properly recognize when a file is not CSS");
  });

  describe("isJavascript function", function(){
    it("will properly recognize a JavaScript file");
    it("will properly recognize when a file is not JavaScript");
  });

  describe("isVendorCSS function", function(){
    it("will properly recognize a Vendor CSS file");
    it("will properly recognize when a vendor file that is not CSS");
    it("will properly recognize when a CSS file that is not vendor");
  });

  describe("isVendorJS function", function(){
    it("will properly recognize a Vendor JS file");
    it("will properly recognize when a vendor file that is not JS");
    it("will properly recognize when a JS file that is not vendor");
  });

  describe("isCSS function", function(){
    it("will properly recognize a CSS file");
    it("will properly recognize when a file is not CSS");
  });

  describe("mkdirRecursive function", function() {
    describe("will make a directory recursively", function(){
      it("one level deep");
      it("five levels deep");
    });

    it("will throw an error if asked to make a directory that exists as a file")
    it("will exit gracefully, doing nothing, if asked to make a directory that exists");
  });

  describe("write file function", function() {
    it("will write a file");
    it("will write a file inside a directory that does not exist");
    it("will return error if write failed");
  });

  describe("is file newer function", function() {
    describe("will report the first file as newer", function() {
      it("if the second file passed in is null");
      it("if the second file does not exist");
      it("if the first file is newer")
    });
    describe("will report the second file as newer", function() {
      it("if the first file passed in is null");
      it("if the first file does not exist");
      it("if the second file is newer");
    });
  });

  describe("read dir sync recursive function", function() {
    it("will return files/directories in a folder");
    it("will exclude files specific by string path");
    it("will exclude files specific by regex");
    it("will leave out directories when specified")
  });

})
