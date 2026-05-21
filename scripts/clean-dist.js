const fs = require("fs");
const path = require("path");

const distDir = path.join(__dirname, "..", "dist");

const EXE_PATTERN = /^Spotify VORB Setup (\d+\.\d+\.\d+)(?: \((\d+)\))?\.exe$/;

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

  // Parse all EXEs
  const exes = entries
    .filter(e => e.isFile() && EXE_PATTERN.test(e.name))
    .map(e => {
      const m = e.name.match(EXE_PATTERN);
      return { name: e.name, version: m[1], copy: m[2] ? parseInt(m[2]) : 0 };
    });

  // Step 1: For each version, keep only the latest copy (highest copy number, or the base if no copies)
  const byVersion = {};
  for (const e of exes) {
    if (!byVersion[e.version]) byVersion[e.version] = [];
    byVersion[e.version].push(e);
  }

  const toDelete = [];

  for (const [ver, copies] of Object.entries(byVersion)) {
    if (copies.length > 1) {
      // Prefer the base version (copy=0) over numbered copies
      copies.sort((a, b) => a.copy - b.copy); // 0 first, then 1, 2, 3...
      const keep = copies[0];
      for (let i = 1; i < copies.length; i++) {
        toDelete.push(copies[i].name);
      }
      console.log(`  deduped ${ver}: kept "${keep.name}", removed ${copies.length - 1} older copy(ies)`);
    }
  }

  // Step 2: Keep only the latest 3 unique versions
  const uniqueVersions = Object.keys(byVersion).sort((a, b) => versionGt(a, b) ? -1 : 1);

  if (uniqueVersions.length > 3) {
    const keepVersions = new Set(uniqueVersions.slice(0, 3));
    for (const e of exes) {
      if (!keepVersions.has(e.version)) {
        toDelete.push(e.name);
      }
    }
  }

  // Delete files
  for (const file of toDelete) {
    const filePath = path.join(distDir, file);
    try {
      fs.unlinkSync(filePath);
      console.log(`  deleted: ${file}`);
    } catch (err) {
      console.error(`  failed to delete ${file}: ${err.message}`);
    }
  }

  const remaining = Object.keys(byVersion).length;
  console.log(`clean-dist: ${remaining} unique version(s) remaining`);
}

clean();
