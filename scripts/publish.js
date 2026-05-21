const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const pkg = require('../package.json');
const version = pkg.version;

const installerName = `Spotify VORB Setup ${version}.exe`;
const installerPath = path.join(__dirname, '..', 'dist', installerName);
const latestYmlPath = path.join(__dirname, '..', 'dist', 'latest.yml');

if (!fs.existsSync(installerPath)) {
  console.error(`Error: Installer not found at ${installerPath}`);
  console.error('Run npm run build first.');
  process.exit(1);
}

if (!fs.existsSync(latestYmlPath)) {
  console.error(`Error: latest.yml not found at ${latestYmlPath}`);
  console.error('Run npm run build first.');
  process.exit(1);
}

console.log(`Publishing v${version} to GitHub Releases...`);
console.log(`Installer: ${installerName}`);

let ghCmd = 'gh';
try {
  execSync('gh --version', { stdio: 'pipe' });
} catch {
  const knownPaths = [
    'C:\\Program Files\\GitHub CLI\\gh.exe',
    'C:\\Program Files (x86)\\GitHub CLI\\gh.exe',
  ];
  const found = knownPaths.find(p => fs.existsSync(p));
  if (found) ghCmd = `"${found}"`;
  else {
    console.error('Error: GitHub CLI (gh) not found.');
    console.error('Install from https://cli.github.com/ or set GH_TOKEN for manual upload.');
    console.error('\nManual upload steps:');
    console.error(`1. Go to https://github.com/TopiACutie/spotify-vorb/releases/new`);
    console.error(`2. Tag: v${version}`);
    console.error(`3. Title: v${version}`);
    console.error(`4. Upload: ${installerName}`);
    console.error(`5. Upload: latest.yml`);
    process.exit(1);
  }
}

try {
  // Check if release already exists
  try {
    execSync(`${ghCmd} release view v${version}`, { stdio: 'pipe' });
    console.log(`Release v${version} already exists, uploading assets...`);
    execSync(`${ghCmd} release upload v${version} "${installerPath}" "${latestYmlPath}" --clobber`, { stdio: 'inherit' });
  } catch {
    // Create new release
    console.log(`Creating release v${version}...`);
    const changelog = getChangelogEntry(version);
    const tempNotes = path.join(__dirname, '..', 'dist', 'release-notes.md');
    fs.writeFileSync(tempNotes, changelog, 'utf8');
    execSync(`${ghCmd} release create v${version} "${installerPath}" "${latestYmlPath}" --title "v${version}" --notes-file "${tempNotes}"`, { stdio: 'inherit' });
    fs.unlinkSync(tempNotes);
  }
  console.log(`\nPublished v${version} successfully!`);
  console.log('Users will receive the update on next launch.');
} catch (error) {
  console.error('Publish failed:', error.message);
  process.exit(1);
}

function getChangelogEntry(ver) {
  const changelogPath = path.join(__dirname, '..', 'CHANGELOG.md');
  if (!fs.existsSync(changelogPath)) return `Spotify VORB v${ver}`;

  const content = fs.readFileSync(changelogPath, 'utf8');
  const lines = content.split('\n');
  const startIdx = lines.findIndex(l => l.startsWith(`## v${ver}`));
  if (startIdx === -1) return `Spotify VORB v${ver}`;

  // Find the next version header or end of relevant section
  const endIdx = lines.findIndex((l, i) => i > startIdx && l.startsWith('## v'));
  const section = lines.slice(startIdx, endIdx === -1 ? undefined : endIdx).join('\n');

  // Convert markdown to release notes format
  return section;
}
