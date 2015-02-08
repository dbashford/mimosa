var exec = require('child_process').exec
  , wrench = require( "wrench" )
  , utils = require( "../../utils" )
  ;

var runTest = function(testSpec, project, codebase, test) {
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
      exec( "mimosa build", function ( err, sout, serr ) {
        exec( "mimosa clean", function ( err, sout, serr ) {
          test(sout, projectData, function() {
            done();
            process.chdir(cwd);
          });
        });
      });
    });
  });
};

var filesDirectoriesInFolder = function(dir){
  return wrench.readdirSyncRecursive(dir).length;
}

var basicRun = function(cleanLoc) {
  return function(sout, projectData, done) {
    var assetCount = filesDirectoriesInFolder(projectData.publicDir);
    expect(sout.indexOf("has been cleaned.")).to.above(cleanLoc);
    expect(assetCount).to.eql(0);
    done();
  };
};

describe("Mimosa's cleaner", function() {

  runTest(
    "when processing completes will remove all code and call the finish callback",
    "cleaner/clean",
    "basic",
    basicRun(900)
  );

  runTest(
    "will ignore files when configured to ignore files",
    "cleaner/exclude",
    "basic",
    function(sout, projectData, done) {
      var assetCount = filesDirectoriesInFolder(projectData.publicDir);
      expect(sout.indexOf("has been cleaned.")).to.be.above(900);
      expect(sout.indexOf("requirejs/require.js")).to.be.above(300);
      expect(sout.indexOf("main.js")).to.eql(-1);
      expect(assetCount).to.eql(0);
      done();
    }
  );

  runTest(
    "works when setting interval",
    "cleaner/interval",
    "basic",
    basicRun(900)
  );

  runTest(
    "works when setting polling to false",
    "cleaner/polling",
    "basic",
    basicRun(900)
  );

  runTest(
    "will clean and exit when no files in asset directory",
    "cleaner/empty",
    "empty",
    basicRun(50)
  );
});
