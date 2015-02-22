// move to configurer tests
describe("will apply profiles", function() {
  it("from a .mimosa_profile directory");
  it("when multiple in a .mimosa_profile directory");
  it("when added from the command line");
  it("when multiple added from the command line");
  describe("in the proper order", function() {
    it("when multiple profiles in .mimosa_profile");
    it("when multiple profiles at command line");
    it("when both .mimosa_profile and command line profile listed");
    it("when multiple .mimosa_profile and command line profiles are entered");
  });
});

describe("will set proper config flags", function() {
  it("--optimize");
  it("-o");
  it("--minify");
  it("-m");
  it("--package");
  it("-p");
  it("--install");
  it("-i");
  it("--errorout");
  it("-e")
  it("--cleanall");
  it("-C");
  it("--mdebug");
  it("-D");
  it("-ompieCDP foo");
  it("--optimize --minify --package --install --errorout --cleanall --mdebug --profile foo")
});
