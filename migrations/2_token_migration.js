const Token = artifacts.require('Token');
const Exchange = artifacts.require('Exchange');

module.exports = async function(deployer, network, accounts) {
  let tokenA;
  let tokenB;

  await deployer
    .deploy(Token, 'Token A', 'A', 18, 100, {
      from: accounts[0]
    })
    .then(instance => {
      tokenA = instance.address;
    });

  await deployer
    .deploy(Token, 'Token B', 'B', 18, 100, {
      from: accounts[1]
    })
    .then(instance => {
      tokenB = instance.address;
    });

  await deployer.deploy(Exchange, tokenA, tokenB, {
    from: accounts[0]
  });
};
