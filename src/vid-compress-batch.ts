// bun run src/vid-compress-batch.ts '/Users/livshitz/Downloads/to-compress/' -s=0.1 -r=0.1 --dest='/Users/livshitz/Downloads/to-compress/compressed'

import { libx } from "libx.js/build/bundles/node.essentials";
import { compress } from "./vid-compress";

const args = libx.node.args;
const folder = args._[0];
const dest = args.dest;
const scaleRatio = args.s;
const scaleBitrate = args.b;
const videoExtensions = ["mp4", "avi", "mkv", "mov", "flv", "wmv", "webm", "mpeg", "mpg"];

const pattern = `${folder}/*.@(${videoExtensions.join('|')})`;
console.log('pattern: ', pattern);

async function run() {	
	const files = libx.node.getFilesSync(pattern);
	
	for(let file of files) {
		libx.log.v('processing file', file);
		const res = await compress(file, scaleRatio, scaleBitrate, dest);
		libx.log.i(`done processing file. Compression rate: ${(100 - (parseInt(res.destSize)/parseInt(res.srcSize) * 100)).toFixed(2)}%`);
	}
	
	console.log('files: ', files)
}

run();