# Split

A contract to mint NFTs and split the balance with key stake holders of an ERC20 contract.

## Installation

Install [foundry](https://github.com/gakonst/foundry) and run `forge install` to install all the dependencies. Then run `forge test` to test the contracts.

## Deploy

```bash
forge create --rpc-url $RINKEBY_RPC_URL --constructor-args <STAKE-ERC20-ADDRESS> <NAME> <SYMBOL> <TOTALSUPPLY> --private-key $TEST_PRIVATE_KEY src/Split.sol:Split
```

## Usage

First mint `$STAKE` to any number of wallets.

Then change `Stake` and `Split` contract addresses in `config` and run `callKeyStakeHolders.js` from `scripts` after deploying the contract to get the key stake holders (at least, 100,000 `$STAKE`).

## Deployed Contract Address

Deployed address can be found in `config/config.json`.

## Rinkeby Links

STAKE-ERC20 - `https://rinkeby.etherscan.io/address/0xd2682bdb4f886803d88ec4797d63b87501d7107c`

SPLIT - `https://rinkeby.etherscan.io/address/0xd2682bdb4f886803d88ec4797d63b87501d7107c`

## Disclaimer
Not in production. So please don't use it.