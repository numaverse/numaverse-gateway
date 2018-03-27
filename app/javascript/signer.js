const eth = require('ethjs-abi');
const _ = require('underscore');

const contractName = process.argv[2];
const NumaContract = require(`../../build/contracts/${contractName}.json`);

const method = _.findWhere(NumaContract.abi, { name: process.argv[3]});
const signed = eth.encodeMethod(method, process.argv.slice(4));


console.log(signed);