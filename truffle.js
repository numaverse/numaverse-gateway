module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    ganache: {
      network_id: 1,
      host: '127.0.0.1',
      port: 7545
    },
    dev_node: {
      network_id: 269,
      host: '127.0.0.1',
      port: 1095
    },
    dev_node2: {
      network_id: 271,
      host: '127.0.0.1',
      port: 1095
    },
    parity_dev: {
      network_id: 273,
      host: '127.0.0.1',
      port: 8545,
    },
    numa_dev1_geth: {
      network_id: 274,
      host: '127.0.0.1',
      port: 1095
    },
    numa_dev1_parity: {
      network_id: 274,
      host: 'localhost',
      port: 8545,
      gas: 0
    }
  },
  rpc: {
    host: "127.0.0.1",
    port: 1095
  }
};