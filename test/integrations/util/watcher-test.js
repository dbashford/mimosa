var exec = require('child_process').exec
  , wrench = require( "wrench" )
  , utils = require( "../../utils" )
  ;

var runTest = function(testSpec, project, codebase, cmd, test) {
  describe("", function() {
    var projectData;

    before(function(){
      projectData = utils.setupProjectData( project );
      utils.cleanProject( projectData );
      utils.setupProject( projectData, codebase );
    });

    after(function(){
      utils.cleanProject( projectData );
    })

    it(testSpec, function(done){
      var cwd = process.cwd();
      process.chdir( projectData.projectDir );
      exec( "mimosa " + cmd, function ( err, sout, serr ) {
        test(sout, projectData, function() {
          done();
          process.chdir(cwd);
        });
      });
    });
  });
};

var filesDirectoriesInFolder = function(dir){
  return wrench.readdirSyncRecursive(dir).length;
}

var basicBuild = function(finishedLoc, filesOut) {
  return function(sout, projectData, done) {
    var assetCount = filesDirectoriesInFolder(projectData.publicDir);
    expect(sout.indexOf("Finished build")).to.be.above(finishedLoc);
    expect(assetCount).to.eql(filesOut);
    done();
  };
};

describe("Mimosa's watcher", function() {

  describe("on mimosa build", function() {

    runTest(
      "will run and exit successfully when there are no files in the asset directory",
      "watcher/build-empty",
      "empty",
      "build",
      basicBuild(100, 0)
    );

    describe("will process all of a projects files into the public directory", function() {

      var basicTest = basicBuild(500, 11);

      runTest(
        "with the default config",
        "watcher/build",
        "basic",
        "build",
        basicTest
      );

      runTest(
        "when throttle is set",
        "watcher/build-throttle",
        "basic",
        "build",
        basicTest
      );

      runTest(
        "when delay is set",
        "watcher/build-delay",
        "basic",
        "build",
        basicTest
      );

      runTest(
        "when interval is set",
        "watcher/build-interval",
        "basic",
        "build",
        basicTest
      );

      runTest(
        "when polling is set to false",
        "watcher/build-polling",
        "basic",
        "build",
        basicTest
      );
    });

    describe("will exclude files from being processed into the public directory", function() {
      runTest(
        "via string match",
        "watcher/build-exclude-string",
        "basic",
        "build",
        basicBuild(400, 8)
      );

      runTest(
        "via regex match",
        "watcher/build-exclude-regex",
        "basic",
        "build",
        basicBuild(400, 8)
      );

      runTest(
        "via both string and regex match",
        "watcher/build-exclude-both",
        "basic",
        "build",
        basicBuild(400, 8)
      );
    });
  });

  describe("on mimosa watch", function() {

    it("will stop watching and exit when STOPMIMOSA is sent");

    describe("will exclude files from being added into the public directory", function() {
      it("via string exclude");
      it("via regex exclude");
      it("via string and regex exclude");
    });

    describe("after the initial build", function(){
      it("will keep watching");
      it("will process file adds");
      it("will process file deletes");
      it("will process file updates");
      it("will process file moves (add and delete at same time)");

      describe("with throttle engaged", function() {
        it("will process file adds");
        it("will process file moves (add and delete at same time)");
      });

      describe("with delay engaged", function() {
        it("will process file adds")
        it("will process file updates");
        it("will process file moves (add and delete at same time)");
      });
    });

    it("can handle adding file to empty project")

  });

});
