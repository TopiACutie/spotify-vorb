const { exec } = require("child_process");

function isVoicemeeterInstalled() {
  return new Promise((resolve) => {
    exec(
      'powershell -Command "Get-CimInstance Win32_PnPEntity | Where-Object { $_.Name -match \'voicemeeter\' } | Select-Object -ExpandProperty Name"',
      { timeout: 5000 },
      (err, stdout) => {
        resolve(!err && stdout.trim().length > 0);
      }
    );
  });
}

module.exports = { isVoicemeeterInstalled };
