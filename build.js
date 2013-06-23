var path = require('path')
  , exec = require('child_process').exec
  , binPath = path.join(__dirname, "bin", "mimosa");

exec("node " + binPath + " build", function (error, stdout, stderr) {
  console.log('stdout: ' + stdout);
  console.log('stderr: ' + stderr);
  if (error !== null) {
    console.log('exec error: ' + error);
  }
})
