#!/usr/bin/env bun

// $ bun run src/wav2mp3.ts /Users/livshitz/Downloads/ffd20322ebf3a8e25574b420086d0663\ \(2\).wav
// $ run-script.sh wav2mp3.ts /Users/livshitz/Downloads/ffd20322ebf3a8e25574b420086d0663\ \(2\).wav

import Bun from 'bun';
import fs from 'fs';

const args = process.argv.slice(2);

if (args.length < 1) {
	console.error("Usage: bun wav2mp3.ts input.wav [output.mp3]");
	process.exit(1);
}

const inputFile = args[0]; //`\"${args[0]}\"`; 

// Determine output filename
let outputFile = "";
if (args.length >= 2) {
	outputFile = args[1];
} else {
	if (inputFile.toLowerCase().endsWith(".wav")) {
		outputFile = inputFile.slice(0, -4) + ".mp3";
	} else {
		outputFile = inputFile + ".mp3";
	}
}

// Check if ffmpeg is installed
const check = Bun.spawnSync(["which", "ffmpeg"]);
if (check.exitCode !== 0) {
	console.error("Error: ffmpeg is not installed. Please install it first.");
	process.exit(1);
}

console.log(`Converting "${inputFile}" to "${outputFile}"...`);

const exists = fs.existsSync(inputFile);
console.log('exists: ', inputFile, exists);
if (!exists) {
	console.error("Error: input file does not exist.", inputFile);
	process.exit(1);
}

const proc = Bun.spawn([
	"ffmpeg",
	"-y", // overwrite output file if exists
	"-i", inputFile,
	"-codec:a", "libmp3lame",
	"-qscale:a", "2", // high quality VBR
	outputFile,
], {
	stdout: "inherit",
	stderr: "inherit",
});

const exitCode = await proc.exited;

if (exitCode === 0) {
	console.log("Conversion successful!");
} else {
	console.error(`Conversion failed with exit code ${exitCode}`);
}