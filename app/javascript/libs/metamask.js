import Web3 from 'web3';
import EventEmitter from 'wolfy87-eventemitter';
import NumaContract from '../../../build/contracts/Numa.json';
import contract from 'truffle-contract';

const enabled = typeof web3 !== 'undefined';
let web3js = null;
let coinbase = null;
let chainName = 'Development';
let emitter = null;
if (enabled) {
  web3js = new Web3(web3.currentProvider);
  window.metamask = web3js;
  console.log('in web3js', web3js);
  emitter = new EventEmitter();

  coinbase = web3js.eth.accounts[0];

  setInterval(() => {
    const account = web3js.eth.accounts[0];
    if (coinbase != account) {
      coinbase = account;
      emitter.emitEvent('accountChanged', [account]);
    }
  }, 1000);

  if (chainID == 1) {
    chainName = "Ethereum Main";
  } else if (chainID == 3) {
    chainName = "Ropsten Test";
  }
}

export default {
  enabled: enabled,
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
  chainName: chainName,
  coinbase: coinbase,
  convertToUSD(value) {
    return (value * ETH_USD).toFixed(2);
  },
  async contract() {
    if (!contractAddress) {
      return null;
    }
    const _contract = contract(NumaContract, () => { });
    _contract.setProvider(web3js.currentProvider);
    const instance = await _contract.at(contractAddress);
    return instance;
  }
};