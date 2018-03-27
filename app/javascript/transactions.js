// import EthereumTx from 'ethereumjs-tx';
const EthereumTx = require('ethereumjs-tx');

// console.log(process.argv);
const [node, fname, pkey, nonce, from, to, value, data, chainId, gasPrice, gasLimit] = process.argv;

// console.log('node');
// console.log(gasPrice);
// console.log(gasLimit);
// console.log('done');

const privateKey = Buffer.from(pkey, 'hex');

console.log("gas price:", gasPrice);

const txParams = {
  nonce: nonce,
  gasPrice: gasPrice,
  gasLimit: gasLimit,
  from: from,
  to: to,
  value: value,
  data: data,
  chainId: chainId
}

const tx = new EthereumTx(txParams);

tx.sign(privateKey)

const serializedTx = tx.serialize()

console.log(serializedTx.toString('hex'));