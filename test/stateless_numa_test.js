const Numa = artifacts.require("StatelessNuma");
const { web3 } = Numa;
const util = require('util');
const { randomHex, logGasEstimate, assertEvent } = require('./helpers')

contract('StatelessNuma', function (accounts) {
  it('fires an event', async () => {
    const numa = await Numa.deployed();
    let hash = await randomHex();
    await numa.newBatch(hash, { from: accounts[0] });
    await assertEvent(numa, { event: 'NewBatch' });
  });

  it('estimates gas', async () => {
    const numa = await Numa.deployed();
    let hash = await randomHex();
    const gas = await numa.newBatch.estimateGas(hash, { from: accounts[3] });
    logGasEstimate(gas, 'Numa.newBatch');
  });
});