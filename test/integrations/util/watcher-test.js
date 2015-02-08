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

var basicRun = function(cleanLoc) {
  return function(sout, projectData, done) {
    var assetCount = filesDirectoriesInFolder(projectData.publicDir);
    expect(sout.indexOf("has been cleaned.")).to.above(cleanLoc);
    expect(assetCount).to.eql(0);
    done();
  };
};

describe("Mimosa's watcher", function() {

  describe("on mimosa build", function() {

    it("will run and exit successfully when there are no files in the asset directory")

    describe("will process all of a projects files into the public directory", function() {

      it("with the default config", function(){});
      it("when throttle is set", function(){});
      it("when delay is set", function(){});
      it("when interval is set", function(){});
      it("when polling is set to false", function(){});

    });

    describe("will exclude files from being processed into the public directory", function() {
      it("via string match", function(){});
      it("via regex match", function(){});
    });

  });

  describe("on mimosa watch", function() {

    it("will stop watching and exit when STOPMIMOSA is sent", function(){})

    describe("after the initial build", function(){
      it("will keep watching", function(){});
      it("will process file adds", function(){})
      it("will process file deletes", function(){});
      it("will process file updates", function(){});
      it("will process file moves (add and delete at same time)", function(){});
    });

  });

});
