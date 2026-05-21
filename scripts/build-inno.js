// Spotify VORB — Build script for Inno Setup installer
// Overwrites same-version files, keeps latest 3 unique versions

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const pkg = require('../package.json');
const version = pkg.version;

// Find Inno Setup compiler
function findISCC() {
  const isccPaths = [
    process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, 'Programs', 'Inno Setup 6', 'ISCC.exe') : null,
    'C:\\Program Files (x86)\\Inno Setup 6\\ISCC.exe',
    'C:\\Program Files\\Inno Setup 6\\ISCC.exe',
  ].filter(Boolean);

  for (const p of isccPaths) {
    if (fs.existsSync(p)) return p;
  }

  try {
    const result = execSync('where iscc.exe', { encoding: 'utf8' }).trim();
    if (result) return result.split('\n')[0].trim();
  } catch {}

  return null;
}

const iscc = findISCC();

if (!iscc) {
  console.error('Error: Inno Setup compiler (ISCC.exe) not found.');
  console.error('Please install Inno Setup from https://jrsoftware.org/isdl.php');
  process.exit(1);
}

const issFile = path.join(__dirname, 'installer.iss');
if (!fs.existsSync(issFile)) {
  console.error('Error: installer.iss not found at', issFile);
  process.exit(1);
}

const unpackedDir = path.join(__dirname, '..', 'dist', 'win-unpacked');
if (!fs.existsSync(unpackedDir)) {
  console.error('Error: win-unpacked directory not found. Run electron-builder --dir first.');
  process.exit(1);
}

const installerName = `Spotify VORB Setup ${version}.exe`;
const installerPath = path.join(__dirname, '..', 'dist', installerName);

// Delete old installer of same version before building
if (fs.existsSync(installerPath)) {
  try {
    fs.unlinkSync(installerPath);
  } catch (e) {
    console.error('Warning: Could not delete old installer:', e.message);
  }
}

console.log(`Building Inno Setup installer for v${version}...`);
console.log(`Compiler: ${iscc}`);
console.log(`Script: ${issFile}`);

try {
  execSync(`"${iscc}" /DMyAppVersion=${version} "${issFile}"`, { stdio: 'inherit', cwd: __dirname });
  console.log('\nInno Setup build completed successfully.');

  if (!fs.existsSync(installerPath)) {
    console.error('Warning: Installer output not found at expected location.');
    process.exit(1);
  }

  const stats = fs.statSync(installerPath);
  const sizeMB = (stats.size / (1024 * 1024)).toFixed(2);
  console.log(`Installer: ${installerPath} (${sizeMB} MB)`);

  // Generate latest.yml for electron-updater
  const fileHash = crypto.createHash('sha512').update(fs.readFileSync(installerPath)).digest('base64');
  const latestYml = `version: ${version}
files:
  - url: ${installerName}
    sha512: ${fileHash}
    size: ${stats.size}
path: ${installerName}
sha512: ${fileHash}
releaseDate: '${new Date().toISOString()}'
`;

  const ymlPath = path.join(__dirname, '..', 'dist', 'latest.yml');
  fs.writeFileSync(ymlPath, latestYml, 'utf8');
  console.log(`\nlatest.yml generated for auto-updates:`);
  console.log(`  Version: ${version}`);
  console.log(`  Size: ${stats.size} bytes`);
  console.log(`  SHA512: ${fileHash.substring(0, 40)}...`);
} catch (error) {
  console.error('Inno Setup build failed:', error.message);
  process.exit(1);
}
