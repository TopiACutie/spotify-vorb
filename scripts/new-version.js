const fs = require("fs");
const path = require("path");

const pkgPath = path.join(__dirname, "..", "package.json");
const changelogPath = path.join(__dirname, "..", "CHANGELOG.md");

const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf-8"));
const currentVersion = pkg.version;

const bump = process.argv[2] || "patch";
const description = process.argv.slice(3).join(" ") || "";

const parts = currentVersion.split(".").map(Number);
let nextVersion;

if (/^\d+\.\d+\.\d+$/.test(bump)) {
  nextVersion = bump;
} else {
  switch (bump) {
    case "major": nextVersion = `${parts[0] + 1}.0.0`; break;
    case "minor": nextVersion = `${parts[0]}.${parts[1] + 1}.0`; break;
    case "patch": nextVersion = `${parts[0]}.${parts[1]}.${parts[2] + 1}`; break;
    default: console.error("Usage: node scripts/new-version.js [major|minor|patch|X.Y.Z] [description]"); process.exit(1);
  }
}

pkg.version = nextVersion;
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n", "utf-8");

const date = new Date().toISOString().slice(0, 10);
const descLine = description ? `\n${description}\n` : "";

let section, tag;
switch (bump) {
  case "major": section = "### Breaking"; tag = "revamp"; break;
  case "minor": section = "### Added"; tag = "feature"; break;
  default: section = "### Fixed"; tag = "fix"; break;
}

const entry = `\n## v${nextVersion} (${date})${descLine}\n${section}\n- \n\n### Changed\n- \n\n### Fixed\n- \n`;

const existing = fs.readFileSync(changelogPath, "utf-8");
const headerEnd = existing.indexOf("\n\n") + 2;
const updated = existing.slice(0, headerEnd) + entry + existing.slice(headerEnd);
fs.writeFileSync(changelogPath, updated, "utf-8");

console.log(`\n  ${currentVersion} → ${nextVersion}  (${bump} — ${tag})`);
if (description) console.log(`  "${description}"`);
console.log(`  ${date}`);
console.log(`\n  ✓ package.json bumped`);
console.log(`  ✓ CHANGELOG.md: template inserted at top`);
console.log(`\n  ✎  Fill in the changelog details under each heading.`);
console.log(`     Keep it human-friendly: explain what changed and why,`);
console.log(`     not just what files were touched.`);
console.log(`\n  Then run: npm run build\n`);
