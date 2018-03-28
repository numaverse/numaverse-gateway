const eth = require('ethjs-abi');
const _ = require('underscore');

const NumaContract = require(`../../build/contracts/Numa.json`);

const method = _.findWhere(NumaContract.abi, { name: process.argv[2]});
const signed = eth.encodeMethod(method, process.argv.slice(3));


console.log(signed);