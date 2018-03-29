const decoder = require('abi-decoder');

const NumaContract = require(`../../../build/contracts/StatelessNuma.json`);
// const Logs = require('../../../tmp/contract-logs.json');

decoder.addABI(NumaContract.abi);

// path = process.argv[2];
// console.log(path)
// logs = require(path);
// console.log(path.logs)
// const arg = process.argv.slice(2).join('');
// const buffer = Buffer.from(arg, 'base64');
// console.log(buffer.toString());

// console.log(json);

const data = decoder.decodeMethod(process.argv[2]);

console.log(JSON.stringify(data));