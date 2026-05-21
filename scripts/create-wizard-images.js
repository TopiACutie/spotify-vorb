const fs = require('fs');

function createBMP(width, height, bgColor, accentColor, fileName) {
  const rowSize = Math.ceil((width * 3) / 4) * 4;
  const pixelSize = rowSize * height;
  const fileSize = 54 + pixelSize;

  const buf = Buffer.alloc(fileSize);

  // BMP Header (14 bytes)
  buf.writeUInt8(0x42, 0); buf.writeUInt8(0x4D, 1);
  buf.writeUInt32LE(fileSize, 2);
  buf.writeUInt32LE(0, 6);
  buf.writeUInt32LE(54, 10);

  // DIB Header (40 bytes)
  buf.writeUInt32LE(40, 14);
  buf.writeInt32LE(width, 18);
  buf.writeInt32LE(height, 22);
  buf.writeUInt16LE(1, 26);
  buf.writeUInt16LE(24, 28);
  buf.writeUInt32LE(0, 30);
  buf.writeUInt32LE(pixelSize, 34);
  buf.writeInt32LE(2835, 38);
  buf.writeInt32LE(2835, 42);
  buf.writeUInt32LE(0, 46);
  buf.writeUInt32LE(0, 50);

  const [br, bg, bb] = bgColor;
  const [ar, ag, ab] = accentColor;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const pixelOffset = 54 + (height - 1 - y) * rowSize + x * 3;

      // Dark background with subtle gradient
      const gradFactor = y / height;
      let r = Math.round(br + (ar - br) * gradFactor * 0.15);
      let g = Math.round(bg + (ag - bg) * gradFactor * 0.15);
      let b = Math.round(bb + (bb - bb) * gradFactor * 0.15);

      // Green accent line at top
      if (y < 3) {
        r = ar; g = ag; b = ab;
      }

      // VORB "logo" area - simple geometric pattern
      if (x > width * 0.3 && x < width * 0.7 && y > height * 0.2 && y < height * 0.8) {
        const cx = width / 2, cy = height / 2;
        const dist = Math.sqrt((x - cx) ** 2 + (y - cy) ** 2);
        if (dist < 40) {
          const intensity = 1 - dist / 40;
          r = Math.round(r + (ar - r) * intensity * 0.3);
          g = Math.round(g + (ag - g) * intensity * 0.3);
          b = Math.round(b + (ab - b) * intensity * 0.3);
        }
      }

      buf.writeUInt8(b, pixelOffset);
      buf.writeUInt8(g, pixelOffset + 1);
      buf.writeUInt8(r, pixelOffset + 2);
    }
  }

  fs.writeFileSync(fileName, buf);
  console.log(`Created ${fileName} (${width}x${height}, ${(fileSize / 1024).toFixed(1)} KB)`);
}

// Wizard large image (164x314 for modern wizard left panel)
createBMP(164, 314, [26, 26, 26], [29, 185, 84], 'assets/wizard-large.bmp');

// Wizard small image (not used in modern style, but required)
createBMP(50, 50, [26, 26, 26], [29, 185, 84], 'assets/wizard-small.bmp');
