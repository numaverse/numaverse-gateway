var Numa = artifacts.require("Numa");
var StatelessNuma = artifacts.require("StatelessNuma");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Numa);
  deployer.deploy(StatelessNuma);
};