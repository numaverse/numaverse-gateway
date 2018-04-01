const crypto = require('crypto');
const _ = require('underscore');

module.exports = {
  randomHex: function () {
    return new Promise((resolve, reject) => {
      crypto.randomBytes(32, (err, buffer) => {
        if (err) {
          reject(err);
        } else {
          resolve('0x' + buffer.toString('hex'));
        }
      });
    });
  },
  assertEvent: function (contract, filter) {
    return new Promise((resolve, reject) => {
      var event = contract[filter.event]();
      event.watch();
      event.get((error, logs) => {
        // console.log(logs);
        var log = _.filter(logs, filter);
        if (log) {
          resolve(log);
        } else {
          throw Error("Failed to find filtered event for " + filter.event);
        }
      });
      event.stopWatching();
    });
  },
  logGasEstimate: function(gas, fn) {
    console.log(`Gas estimation for ${fn}: ${gas} wei`);
    const gasPrice = web3.toWei(1, 'gwei');
    const totalGas = gasPrice * gas;
    const ethCost = web3.fromWei(totalGas, 'ether');
    // console.log(web3.fromWei(totalGas, 'szabo'));
    console.log(`Total gas cost (@ 1 Gwei): ${ethCost} ETH`);
    console.log(`Estimated cost in $USD, assuming $1000 USD / ETH: $${(ethCost * 1000).toFixed(4)}`);
    console.log(`Estimated cost in $USD, assuming $600 USD / ETH: $${(ethCost * 600).toFixed(4)}`);
  }
}