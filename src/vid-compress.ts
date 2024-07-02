// bun run debug src/vid-compress.ts '/Users/livshitz/Downloads/to-compress/7edf27efab1b6f415c886f77fc0b13f0.mp4' 0.4 0.4 '/Users/livshitz/Downloads/to-compress/compressed'

import { execSync } from 'child_process';
import { basename, join } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { libx } from "libx.js/build/bundles/node.essentials";

const minBitrate = 200;
const minWidth = 270;

export function getFileSize(filePath: string): string {
	const commandOutput = execSync(`du -sh "${filePath}"`).toString();
	const size = commandOutput.split('\t')[0];  // Assuming the output is "25M\t/path/to/file"
	return size;
}

export async function compress(src: string, scaleRatio: number, bitrateRatio?: number, outputFolder: string = './') {
	const dur = libx.Measurement.start();
	console.log('args: ', { src, scaleRatio, bitrateRatio, outputFolder });

	if (!src || !scaleRatio) {
		console.error('Usage: node script.js <input_file> <scale_ratio> [bitrate_ratio] [output_folder]');
		process.exit(1);
	} 
	
	bitrateRatio = bitrateRatio || scaleRatio;
	const filenameWithExtension = basename(src);
	const filenameWithoutExtension = filenameWithExtension.split('.').slice(0, -1).join('.');
	let dest = `${outputFolder}/${filenameWithoutExtension}-out.mp4`;

	if (!existsSync(outputFolder)) {
		mkdirSync(outputFolder, { recursive: true });
	}

	const originalBitrate = parseInt(execSync(`ffprobe -v error -select_streams v:0 -show_entries stream=bit_rate -of default=noprint_wrappers=1:nokey=1 "${src}"`).toString());
	let newBitrate = Math.round((originalBitrate / 1000) * bitrateRatio * bitrateRatio);
	if (newBitrate < minBitrate) newBitrate = minBitrate;

	const width = parseInt(execSync(`ffprobe -v error -select_streams v:0 -show_entries stream=width -of default=noprint_wrappers=1:nokey=1 "${src}"`).toString());
	const height = parseInt(execSync(`ffprobe -v error -select_streams v:0 -show_entries stream=height -of default=noprint_wrappers=1:nokey=1 "${src}"`).toString());

	let newWidth = Math.round(width * scaleRatio);
	let newHeight = Math.round(height * scaleRatio);
	if (newWidth < minWidth) {
		newWidth = minWidth;
		newHeight = newWidth/width * height;
	}

	console.log('----');
	let config = { 
		src, scaleRatio, bitrateRatio, dest, 
		originalBitrate, 
		width, height,
		newBitrate,
		newWidth, newHeight,
		srcSize: '', destSize: '',
	};
	console.log(`config: `, config);
	console.log('----');

	execSync(`ffmpeg -i "${src}" -vf "scale=${newWidth}:${newHeight}" -b:v "${newBitrate}k" -c:a copy "${dest}" -loglevel error -y`);
	const srcSize = getFileSize(src);
	const destSize = getFileSize(dest);
	console.log(`Original file size: ${srcSize}`);
	console.log(`Output file size: ${destSize}`);
	console.log(`Dur: ${dur.peek()}ms`);
	
	config.srcSize = srcSize;
	config.destSize = destSize;

	return config;
}

// main(libx.node.args)
if (libx.node.isCalledDirectly()) {
	const args = libx.node.args;
	compress.apply(this, args._);
}

// Example usage: node vid-compress.ts './video.mp4' 1.5 1.2 './output/'
