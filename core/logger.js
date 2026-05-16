const fs = require("fs");
const path = require("path");

const LOG_DIR = path.join(__dirname, "..", "settings");
const LOG_FILE = path.join(LOG_DIR, "debug.log");

function ensureDir() {
  try {
    if (!fs.existsSync(LOG_DIR)) {
      fs.mkdirSync(LOG_DIR, { recursive: true });
    }
  } catch {}
}

function pad(n) { return String(n).padStart(2, "0"); }

function write(level, source, message, data) {
  try {
    ensureDir();
    const d = new Date();
    const ts = d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + " " + pad(d.getHours()) + ":" + pad(d.getMinutes()) + ":" + pad(d.getSeconds());
    let line = `[${ts}] [${level}] [${source}] ${message}`;
    if (data !== undefined) {
      const str = typeof data === "object" ? JSON.stringify(data) : String(data);
      line += ` | ${str.slice(0, 500)}`;
    }
    fs.appendFileSync(LOG_FILE, line + "\n", "utf-8");
  } catch {}
}

function info(source, message, data) { write("INFO", source, message, data); }
function warn(source, message, data) { write("WARN", source, message, data); }
function error(source, message, data) { write("ERROR", source, message, data); }

function clear() {
  try {
    ensureDir();
    fs.writeFileSync(LOG_FILE, "", "utf-8");
  } catch {}
}

module.exports = { info, warn, error, clear };
