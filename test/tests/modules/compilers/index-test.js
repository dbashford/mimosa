describe("Mimosa's compiler manager", function() {

  describe("when checking multiple template library use", function() {
    it("will catch when multiple template libraries used");
    describe("will continue the workflow", function() {
      it("if no template files");
      it("if template object configured");
    })
  });

  describe("when setting up compilers", function() {
    describe("will build list of extensions", function() {
      it("when single compiler");
      it("when multiple compilers");
      it("and not inspect modules that are not compilers");
      it("and will keep extensions per type unique");
      it("and will resort compilers")
    })
  });

  describe("when registering", function() {
    it("will instantiate all the master compilers and pass in the child compilers");
    it("will set the compiler name on the instance");
    it("will register the compiler instances");
    it("will call child registration functions if they exist");
    it("will register the dupe template checker")
    it("will not register the dupe template checker if templates are not configured")
  });

  it("returns the proper defaults");

  describe("validation", function() {
    it("will fail if resortCompilers isnt a boolean");
    it("will fail if template isn't an object");
    it("will fail if writeLibrary isnt a boolean");
    it("will fail if wrapType isnt a string");
    it("will fail if wrapType isn't proper setting"); // "common", "amd", "none"
    it("will fail if nameTransform isn't string, regex or function");
    it("will fail if nameTransform is a string and isn't fileName or filePath");
    describe("for template naming", function() {
      it("will transform outputFileName into output format");
      it("will fail if outputFileName is not a string");
      it("will fail if output.folders is not an array or is an array of length 0");
      it("will fail if a folder doesn't exist on the file system");
      it("will fail if outputFileName does not exist");
      it("will fail if outputFileName is not an object or string");
      it("will resolve folders to full paths");
      it("will build proper output structure");
    });
  });
});