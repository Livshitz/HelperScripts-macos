import * as fs from 'fs';
import * as path from 'path';
import { libx } from "libx.js/build/bundles/node.essentials";

/**
 * Reads a JSON file and converts its content into a one-line string.
 * @param filePath - The path to the JSON file.
 * @returns A promise that resolves to a one-line string representing the JSON content.
 */
async function jsonToOneLineString(filePath: string): Promise<string> {
    try {
        const data = await fs.promises.readFile(filePath, 'utf8');
        const jsonObject = JSON.parse(data);
        let ret = JSON.stringify(jsonObject);
        // ret = escapeSpecialChars(ret);
        return ret;
    } catch (error) {
        throw error;
    }
}

function escapeSpecialChars(str: string) {
    const escapeMap = <any>{
        '\\': '\\\\',
        '"': '\\"',
        "'": "\\'",
        '\n': '\\n',
        '\r': '\\r',
        '\t': '\\t',
        '\b': '\\b',
        '\f': '\\f',
        '\v': '\\v',
        '\0': '\\0',
        '\u2028': '\\u2028',
        '\u2029': '\\u2029'
    };

    return str.replace(/[\u0000-\u001F\u2028\u2029\\'"']/g, function(char) {
        return escapeMap[char] || '\\u' + char.charCodeAt(0).toString(16).padStart(4, '0');
    });
}

// Example usage:
(async () => {
	const input = libx.node.args._[0];
    // const input = path.join(__dirname, libx.node.args.in);
    
    try {
        const oneLineString = await jsonToOneLineString(input);
        console.log(oneLineString);
		return oneLineString;
    } catch (error) {
        console.error('Error:', error);
    }
})();