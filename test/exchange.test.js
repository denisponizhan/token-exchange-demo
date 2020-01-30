const Token = artifacts.require('Token');
const Exchange = artifacts.require('Exchange');

contract('Exchange pair of tokens', async accounts => {
  let tokenA;
  let tokenB;
  let exchange;

  it('should put 100 Token A in the first account', async () => {
    tokenA = await Token.new('Token A', 'A', 18, 100, {
      from: accounts[0]
    });
    let balance = await tokenA.balanceOf.call(accounts[0]);
    assert.equal(balance.toNumber(), 100, 'User balance should be equal 100');
  });

  it('should put 100 Token B in the second account', async () => {
    tokenB = await Token.new('Token B', 'B', 18, 100, {
      from: accounts[1]
    });
    let balance = await tokenB.balanceOf.call(accounts[1]);
    assert.equal(balance.toNumber(), 100, 'User balance should be equal 100');
  });

  it('should put symbol A as Token A symbol', async () => {
    let A = await Token.at(tokenA.address);
    let symbol = await A.symbol.call();
    assert.equal(symbol, 'A', 'Token symbol should be equal A');
  });

  it('should put symbol B as Token B symbol', async () => {
    let B = await Token.at(tokenB.address);
    let symbol = await B.symbol.call();
    assert.equal(symbol, 'B', 'Token symbol should be equal B');
  });

  it('should set approval for exchange contract to spend Token A', async () => {
    exchange = await Exchange.new(tokenA.address, tokenB.address);
    await tokenA.approve(exchange.address, 100, { from: accounts[0] });
    let allowed = await tokenA.allowance.call(accounts[0], exchange.address);
    assert.equal(allowed.toNumber(), 100, 'Allowance should be equal 100');
  });

  it('should set approval for exchange contract to spend Token B', async () => {
    await tokenB.approve(exchange.address, 100, { from: accounts[1] });
    let allowed = await tokenB.allowance.call(accounts[1], exchange.address);
    assert.equal(allowed.toNumber(), 100, 'Allowance should be equal 100');
  });

  it('should swap 10 Token A for 20 Token B between two users', async () => {
    await exchange.sell(2, 10, { from: accounts[0] });
    await exchange.buy(2, 10, { from: accounts[1] });

    let user1balance = await tokenA.balanceOf.call(accounts[1]);
    let user0balance = await tokenB.balanceOf.call(accounts[0]);

    assert.equal(
      user0balance.toNumber(),
      20,
      'User 2 balance should be equal 20 Token B'
    );
    assert.equal(
      user1balance.toNumber(),
      10,
      'User 1 balance should be equal 10 Token A'
    );
  });
});
