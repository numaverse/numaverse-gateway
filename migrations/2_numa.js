var Numa = artifacts.require("Numa");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Numa);
};