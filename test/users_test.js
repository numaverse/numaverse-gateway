const UsersArtifact = artifacts.require("Users");
const { randomHex, assertEvent, logGasEstimate } = require('./helpers')
// const util = require('util');

contract('Users', function (accounts) {
  describe('update', () => {
    it('sets a hash mapped to the sender', async () => {
      const Users = await UsersArtifact.deployed();
      const hash = await randomHex();
      await Users.update(hash, { from: accounts[0] });
      const stored = await Users.users.call(accounts[0]);
      assert.equal(stored, hash, "The proper hash should be stored.")
      await assertEvent(Users, { event: 'UserUpdated' });
    });

    it('estimates gas', async () => {
      const Users = await UsersArtifact.deployed();
      const hash = await randomHex();
      const gas = await Users.update.estimateGas(hash, { from: accounts[1] });
      logGasEstimate(gas, 'Users.update');
    });
  });
});