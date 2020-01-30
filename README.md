# Token demo exchange

This project contains demo version of exchange smart contract.

Features available:

- orderbook;
- orders sort (asks/bids, descending/ascending);
- orders deposit in case of absence of matched order;
- orders matching;

//TODO:

- improve sort algorithm to use less gas;
- use price difference to get profit

## Usage

Use the package manager [npm](https://www.npmjs.com/products/teams?utm_source=adwords&utm_medium=ppc&utm_campaign=npmTeams2019Q2&utm_content=site&gclid=Cj0KCQiAmsrxBRDaARIsANyiD1o4KjOy2lwBlWd2CAVyWThtWmIO1Kq02WarQG9PND39qps1AtgI3csaAvF-EALw_wcB) to install dependencies and then run tests.

```bash
> npm i
> truffle compile --all
> truffle test
```
