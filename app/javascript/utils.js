const Web3 = require('web3');
const web3 = new Web3();

const args = process.argv.slice(2);
let command = args.shift();

console.log(args[0]);

if (command == 'fromAscii') {
  console.log(web3.fromAscii(args[0]));
}

