const Numa = artifacts.require("Numa");
const { web3 } = Numa;
const util = require('util');
const { randomHex, logGasEstimate, assertEvent } = require('./helpers')

contract('Numa', function (accounts) {
  const admin = accounts[0];
  const revertMessage = "Error: VM Exception while processing transaction: revert";

  const assertRevert = async function (promise) {
    let error = null;
    try {
      let res = await promise;
    } catch (e) {
      error = e;
    }
    assert.ok(error, "An error should be raised.");
    assert.equal(revertMessage, error.toString().slice(0, revertMessage.length), "The error should be that the transaction was reverted.");
  }

  const getMessage = async function (numa, _id) {
    const [sender, ipfsHash] = await numa.messages.call(_id);
    return { sender, ipfsHash }
  }

  describe('messages', () => {
    it('has 0 messages to start', async () => {
      const numa = await Numa.deployed();
      assert.equal(await numa.messagesLength.call(), 0);
    });

    describe('createMessage', () => {
      it('works if more than price is sent', async () => {
        const numa = await Numa.deployed();
        const hash = await randomHex();
        await numa.createMessage(hash, { from: accounts[1] });
        const res = await numa.messagesLength.call();
        assert.equal(await numa.messagesLength.call(), 1);
        const message = await getMessage(numa, 0);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[1]);
      });

      it('saves another message', async () => {
        const numa = await Numa.deployed();
        const hash = await randomHex();
        await numa.createMessage(hash, { from: accounts[2] });
        assert.equal(await numa.messagesLength.call(), 2);
        const message = await getMessage(numa, 1);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[2]);
        await assertEvent(numa, { event: 'MessageCreated' });
      });

      it('works again', async () => {
        const numa = await Numa.deployed();
        let hash = await randomHex();
        await numa.createMessage(hash, { from: accounts[3] });
        assert.equal(await numa.messagesLength.call(), 3);
        const message = await getMessage(numa, 2);
        assert.equal(message.sender, accounts[3]);
      });

      it('estimates gas for createMessage', async () => {
        const numa = await Numa.deployed();
        let hash = await randomHex();
        const gas = await numa.createMessage.estimateGas(hash, { from: accounts[3] });
        logGasEstimate(gas, 'Numa.createMessage');
      });
    });

    describe('updateMessage', () => {
      it('updates the first message', async () => {
        const numa = await Numa.deployed();
        let hash = await randomHex();
        await numa.updateMessage(0, hash, { from: accounts[1] });

        assert.equal(await numa.messagesLength.call(), 3);
        const message = await getMessage(numa, 0);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[1]);
        await assertEvent(numa, { event: 'MessageUpdated' });
      });

      it('rejects if youre not the owner', async () => {
        const numa = await Numa.deployed();
        await assertRevert(numa.updateMessage(0, (await randomHex()), { from: admin }));
      });

      it('rejects even for admin if not message owner', async () => {
        const numa = await Numa.deployed();
        await assertRevert(numa.updateMessage(1, (await randomHex()), { from: admin }));
      });

      it('updates a different message', async () => {
        const numa = await Numa.deployed();
        let hash = await randomHex();
        await numa.updateMessage(1, hash, { from: accounts[2] });

        assert.equal(await numa.messagesLength.call(), 3);
        const message = await getMessage(numa, 1);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[2]);
      });

      it('gives a gas cost estimation', async () => {
        const numa = await Numa.deployed();
        let hash = await randomHex();
        const gas = await numa.updateMessage.estimateGas(1, hash, { from: accounts[2] });
        logGasEstimate(gas, 'Numa.updateMessage');
      });

    });

    describe('updateUser', () => {
      it('sets a hash mapped to the sender', async () => {
        const numa = await Numa.deployed();
        const hash = await randomHex();
        await numa.updateUser(hash, { from: accounts[0] });
        const stored = await numa.users.call(accounts[0]);
        assert.equal(stored, hash, "The proper hash should be stored.")
        await assertEvent(numa, { event: 'UserUpdated' });
      });

      it('estimates gas', async () => {
        const numa = await Numa.deployed();
        const hash = await randomHex();
        const gas = await numa.updateUser.estimateGas(hash, { from: accounts[1] });
        logGasEstimate(gas, 'Numa.updateUser');
      });
    });
  });

});