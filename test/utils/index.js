var intSpawn = require( "./integration-spawn" )
  , intProcess = require( "./integration-in-process" )
  , utils = require( "./utils" )
  ;

module.exports = {
  fileFixture: utils.fileFixture,
  fakeMimosaConfig: utils.fakeMimosaConfig,
  testRegistration: utils.testRegistration,
  setupProjectData: utils.setupProjectData,
  setupProject: utils.setupProject,
  cleanProject: utils.cleanProject,
  filesAndDirsInFolder: utils.filesAndDirsInFolder,
  fakeProgram: utils.fakeProgram,

  watchTest: intProcess.watchTest,
  buildTest: intProcess.buildTest,
  cleanTest: intProcess.cleanTest,

  spawn :{
    buildTest: intSpawn.spawnBuildTest,
    buildCleanTest: intSpawn.spawnBuildCleanTest,
    watchTest: intSpawn.spawnWatchTest
  }
};