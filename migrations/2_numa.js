var Messages = artifacts.require("Messages");
var Users = artifacts.require("Users");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(Messages);
  deployer.deploy(Users);
};