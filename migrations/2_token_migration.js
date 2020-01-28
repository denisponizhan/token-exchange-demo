const Token = artifacts.require('Token');

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Token, 'Token A', 'A', 18, 100, { from: accounts[0] });
  deployer.deploy(Token, 'Token B', 'B', 18, 100, { from: accounts[1] });
};
