
describe("Mimosa's CSS compiler utils", function() {

  it("returns proper base options object");

  describe("can determine when a file isn't a compiler file", function() {
    it("when the extension of the file isn't in the list of compiler extensions")
    it("when the extension of the file is .css")
  });

  it("can determine when a file is a compiler file when extension in compiler extension list and extension is not .css");

  describe("can determine if file is include", function() {
    it("if include function is provided");
    it("if include function is not provided and file is in includeToBaseHash");
  });

  describe("can build a destination file", function() {
    it("with the source/public dirs swapped");
    it("ending in .css");
  });

  describe("can get a list of template files", function() {
    it("that contain all the template files");
    it("that do not contain files that are .css when compiler cannot fully import CSS")
  });

  describe("when compiling", function() {
    it("will call callback if no files");
    it("will not attempt to compile files that are not deemed compiler files");
    it("will not attempt to compile files that do not exist");
    it("will log an error if the compile fails");
    it("will set the output text if the compile is successful")
  });

  describe("when pulling base files to compile for updated includes", function() {
    it("will include any base files that do not have output");
    it("will include any base files that have includes that force them to be compiled")
    it("will not include any base files that do not have updated includes");
  });

  describe("when pulling base files to compile", function() {
    it("will include any base files that do not have output");
    it("will include any base files that have been updated since output was created")
    it("will not include any base files that have not been updated since output was created")
  });

  describe("when determining the base files to compile during startup", function() {
    it("will include base files that need compiling from includes");
    it("will include base files that need compiling from base updates");
    it("will not include the same base file twice");
    it("will create base options objects and file entries for each base file");
    it("will set isVendor flag if the first file is a vendor file");
    it("will set isVendor flag on files that need it set");
  });

  describe("when determining the imports in a file", function() {
    it("will return empty array if no includes found");
    it("will return array of imports");
    it("will split imports if compiler supports");
  });

  describe("when determining the full import file path", function() {
    it("will return single entry array if file is .css and compiler supports");
    it("will handle matching for imports that that lack extension");
    it("will match multiple files based on how file starts")
  })


});