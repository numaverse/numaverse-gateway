import Web3 from 'web3';
import EventEmitter from 'wolfy87-eventemitter';
import NumaContract from '../../../build/contracts/Numa.json'
import contract from 'truffle-contract';

let web3js = null;
if (typeof web3 !== 'undefined') {
  web3js = new Web3(web3.currentProvider);
}

window.metamask = web3js;
console.log('in web3js', web3js);
const emitter = new EventEmitter();

let coinbase = web3js.eth.accounts[0];

const coinbaseTimer = setInterval(() => {
  const account = web3js.eth.accounts[0];
  if (coinbase != account) {
    coinbase = account;
    emitter.emitEvent('accountChanged', [account]);
  }
}, 1000);

export default {
  getAccount(callback) {
    if (coinbase) {
      callback(coinbase);
    }
    emitter.addListener('accountChanged', callback);
  },
  web3js: web3js,
  sign(message, callback) {
    web3js.personal.sign(web3js.toHex(message), coinbase, callback);
  },
  coinbase: coinbase,
  async contract() {
    if (!contractAddress) {
      return null;
    }
    const _contract = contract(NumaContract, () => { });
    _contract.setProvider(web3js.currentProvider);
    const instance = await _contract.at(contractAddress);
    return instance;
  }
}