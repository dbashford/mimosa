var exec = require('child_process').exec
  , wrench = require( "wrench" )
  , utils = require( "../../utils" )
  , projectData = utils.setupProjectData( "additional-files")
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


describe("Mimosa's cleaner", function() {

  runTest(
    "when processing completes will remove all code and call the finish callback",
    "cleaner/clean",
    "basic",
    function(sout, projectData, done) {
      var assetCount = filesDirectoriesInFolder(projectData.publicDir);
      expect(sout.indexOf("has been cleaned.")).to.above(900);
      expect(assetCount).to.eql(0);
      done();
    }
  )

  it("will ignore files when configured to ignore files", function(){
    var projectData = utils.setupProjectData( "cleaner/clean" );
  })

  it("works when setting interval", function(){
    var projectData = utils.setupProjectData( "cleaner/interval" );
  });

  it("works when setting binaryInterval", function() {
    var projectData = utils.setupProjectData( "cleaner/binaryInterval" );
  });

  it("works when setting polling", function() {
    var projectData = utils.setupProjectData( "cleaner/polling" );
  });

  it("will clean and exist when no files in asset directory", function() {
    var projectData = utils.setupProjectData( "cleaner/empty" );
  });

});
