const eth = require('ethjs-abi');
const _ = require('underscore');

const NumaContract = require(`../../build/contracts/StatelessNuma.json`);

const method = _.findWhere(NumaContract.abi, { name: 'newBatch'});
const signed = eth.encodeMethod(method, [process.argv[2]]);


console.log(signed);