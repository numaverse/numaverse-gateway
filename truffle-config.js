module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    ganache: {
      network_id: 1,
      host: '127.0.0.1',
      port: 7545
    }
  },
  rpc: {
    host: "127.0.0.1",
    port: 7545
  }
};
