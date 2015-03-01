var intSpawn = require( "./integration/spawn" )
  , intProcess = require( "./integration/in-process" )
  , utils = require( "./utils" )
  ;

module.exports = {

  setup: {
    projectData: utils.setupProjectData,
    project: utils.setupProject,
    cleanProject: utils.cleanProject
  },

  util: {
    filesAndDirsInFolder: utils.filesAndDirsInFolder
  },

  fake: {
    mimosaConfig: utils.fakeMimosaConfig,
    file: utils.fileFixture,
    program: utils.fakeProgram
  },

  test: {
    registration: utils.testRegistration,
    command: {
      watch: intProcess.watchTest,
      build: intProcess.buildTest,
      clean: intProcess.cleanTest,
      flags: {
        help: intProcess.commandHelpTest,
      },
      spawn: {
        build: intSpawn.spawnBuildTest,
        buildClean: intSpawn.spawnBuildCleanTest,
        watch: intSpawn.spawnWatchTest
      }
    }
  }

};