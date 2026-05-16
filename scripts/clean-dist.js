const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "..", "dist");

const EXE_PATTERN = /^Spotify VORB Setup (\d+\.\d+\.\d+)\.exe$/;

function parseVersion(v) {
  return v.split(".").map(Number);
}

function versionGt(a, b) {
  const ap = parseVersion(a);
  const bp = parseVersion(b);
  for (let i = 0; i < 3; i++) {
    if (ap[i] !== bp[i]) return ap[i] > bp[i];
  }
  return false;
}

function clean() {
  if (!fs.existsSync(distDir)) {
    console.log("clean-dist: no dist/ directory found, skipping");
    return;
  }

  const entries = fs.readdirSync(distDir, { withFileTypes: true });
  const exes = entries
    .filter(e => e.isFile() && EXE_PATTERN.test(e.name))
    .map(e => ({ name: e.name, version: e.name.match(EXE_PATTERN)[1] }))
    .sort((a, b) => versionGt(a.version, b.version) ? -1 : 1);

  if (exes.length <= 3) {
    console.log(`clean-dist: ${exes.length} builds found, no cleanup needed`);
    return;
  }

  const keep = new Set();
  const toDelete = [];

  for (let i = 0; i < 3 && i < exes.length; i++) {
    keep.add(exes[i].name);
    keep.add(exes[i].name + ".blockmap");
  }

  for (const e of entries) {
    if (!e.isFile()) continue;
    if (e.name === "latest.yml" || e.name === "builder-debug.yml") continue;
    if (keep.has(e.name)) continue;
    toDelete.push(e.name);
  }

  for (const file of toDelete) {
    const filePath = path.join(distDir, file);
    try {
      fs.unlinkSync(filePath);
      console.log(`  deleted: ${file}`);
    } catch (err) {
      console.error(`  failed to delete ${file}: ${err.message}`);
    }
  }

  console.log(`clean-dist: kept ${keep.size} files, removed ${toDelete.length} old builds`);
}

clean();
