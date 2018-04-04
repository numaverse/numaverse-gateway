module.exports = {
  "extends": [
    'plugin:vue/essential',
    'eslint:recommended'
  ],
  rules: {
    'semi': 1,
    'no-console': 0,
  },
  parserOptions: {
    ecmaVersion: 2017,
    sourceType: 'module'
  },
  env: {
    browser: true,
    jquery: true,
  },
  globals: {
    currentAccount: true,
    contractAddress: true,
    ipfsGatewayAddress: true,
    currentAccountEmail: true,
    ETH_USD: true,
    chainID: true,
    web3: true,
  }
};