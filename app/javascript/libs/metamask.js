import Web3 from 'web3';
import EventEmitter from 'wolfy87-eventemitter';
import UsersContract from '../../../build/contracts/Users.json'
import MessagesContract from '../../../build/contracts/Messages.json'
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
  async usersContract() {
    if (!usersContractAddress) {
      return null;
    }
    const _contract = contract(UsersContract, () => {});
    _contract.setProvider(web3js.currentProvider);
    const instance = await _contract.at(usersContractAddress);
    return instance;
  },
  async messagesContract() {
    if (!messagesContractAddress) {
      return null;
    }
    const _contract = contract(MessagesContract);
    _contract.setProvider(web3js.currentProvider);
    const instance = await _contract.at(messagesContractAddress);
    return instance;
  }
}

// // import NumaContract from '../../build/contracts/Numa.json';
// // const web3 = new Web3();

// import contract from 'truffle-contract';
// import EventEmitter from 'wolfy87-eventemitter';
// import Accounts from 'web3-eth-accounts';

// const promisify = (inner) =>
//   new Promise((resolve, reject) =>
//     inner((err, res) => {
//       if (err) { reject(err) }

//       resolve(res);
//     })
//   );

// // simple proxy to promisify the web3 api. It doesn't deal with edge cases like web3.eth.filter and contracts.
// const proxiedWeb3Handler = {
//   // override getter                               
//   get: (target, name) => {              
//     const inner = target[name];                            
//     if (inner instanceof Function) {                       
//       // Return a function with the callback already set.  
//       return (...args) => promisify(cb => inner(...args, cb));                                                         
//     } else if (typeof inner === 'object') {                
//       // wrap inner web3 stuff                             
//       return new Proxy(inner, proxiedWeb3Handler);         
//     } else {                                               
//       return inner;                                        
//     }                                                      
//   },                                                       
// };                                                         

// const proxiedWeb3 = new Proxy(web3, proxiedWeb3Handler);

// const emitter = new EventEmitter();

// let coinbase = proxiedWeb3.eth.accounts[0];

// const coinbaseTimer = setInterval(() => {
//   const account = proxiedWeb3.eth.accounts[0];
//   if (coinbase != account) {
//     coinbase = account;
//     emitter.emitEvent('account', [account]);
//   }
// }, 1000);

// export default {
//   web3: proxiedWeb3,
//   async contract() {
//     const numaContract = contract(NumaContract);
//     numaContract.setProvider(web3.currentProvider);
//     const instance = await numaContract.deployed();
//     return instance;
//   },
//   account: coinbase,
//   emitter: emitter,
//   createAccount () {
//     const accounts = new Accounts('ws://localhost:1096');
//     const account = web3.eth.accounts.create();
//     window.account = account;
//     console.log(account);
//     return account;
//   }
// };