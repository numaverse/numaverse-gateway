const MessagesArtifact = artifacts.require("Messages");
const { web3 } = MessagesArtifact;
const util = require('util');
const { randomHex, logGasEstimate } = require('./helpers')

contract('Messages', function (accounts) {
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

  const getMessage = async function (messages, _id) {
    const [sender, ipfsHash] = await messages.messages.call(_id);
    return { sender, ipfsHash }
  }

  describe('messages', () => {
    it('has 0 messages to start', async () => {
      const messages = await MessagesArtifact.deployed();
      assert.equal(await messages.messagesLength.call(), 0);
    });

    describe('createMessage', () => {
      it('works if more than price is sent', async () => {
        const messages = await MessagesArtifact.deployed();
        const hash = await randomHex();
        await messages.createMessage(hash, { from: accounts[1]});
        assert.equal(await messages.messagesLength.call(), 1);
        const message = await getMessage(messages, 0);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[1]);
      });

      it('saves another message', async () => {
        const messages = await MessagesArtifact.deployed();
        const hash = await randomHex();
        await messages.createMessage(hash, { from: accounts[2]});
        assert.equal(await messages.messagesLength.call(), 2);
        const message = await getMessage(messages, 1);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[2]);
      });

      it('works again', async () => {
        const messages = await MessagesArtifact.deployed();
        let hash = await randomHex();
        await messages.createMessage(hash, { from: accounts[3] });
        assert.equal(await messages.messagesLength.call(), 3);
        const message = await getMessage(messages, 2);
        assert.equal(message.sender, accounts[3]);
      });

      it('estimates gas for createMessage', async () => {
        const messages = await MessagesArtifact.deployed();
        let hash = await randomHex();
        const gas = await messages.createMessage.estimateGas(hash, { from: accounts[3] });
        logGasEstimate(gas, 'Messages.createMessage');
      });
    });

    describe('updateMessage', () => {
      it('updates the first message', async () => {
        const messages = await MessagesArtifact.deployed();
        let hash = await randomHex();
        await messages.updateMessage(0, hash, { from: accounts[1] });

        assert.equal(await messages.messagesLength.call(), 3);
        const message = await getMessage(messages, 0);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[1]);
      });

      it('rejects if youre not the owner', async () => {
        const messages = await MessagesArtifact.deployed();
        await assertRevert(messages.updateMessage(0, (await randomHex()), { from: admin }));
      });

      it('rejects even for admin if not message owner', async () => {
        const messages = await MessagesArtifact.deployed();
        await assertRevert(messages.updateMessage(1, (await randomHex()), { from: admin }));
      });

      it('updates a different message', async () => {
        const messages = await MessagesArtifact.deployed();
        let hash = await randomHex();
        await messages.updateMessage(1, hash, { from: accounts[2] });

        assert.equal(await messages.messagesLength.call(), 3);
        const message = await getMessage(messages, 1);
        assert.equal(message.ipfsHash, hash);
        assert.equal(message.sender, accounts[2]);
      });

      it('gives a gas cost estimation', async () => {
        const messages = await MessagesArtifact.deployed();
        let hash = await randomHex();
        const gas = await messages.updateMessage.estimateGas(1, hash, { from: accounts[2] });
        logGasEstimate(gas, 'Messages.updateMessage');
      });
      
    });
  });

});