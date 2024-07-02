// bun run debug src/index.ts
// ./run-script-debug.sh index 1 2 3

import { libx } from "libx.js/build/bundles/node.essentials";

console.log("hey", libx.node.args._);
debugger
console.log("Hello via Bun!");