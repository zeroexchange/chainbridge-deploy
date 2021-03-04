# How to deploy

## Prepare contracts

Download contracts, compile them
```bash
cd cb-sol-cli
make install
```

## Ensure deploy commands work

`deploy.sh` also uses `node` and `python3`. To make sure everything works, run:
```
cd deploy
check-js-python.sh
```

## Deploy

First you need to deploy bridge contract, handlers, etc.

In `deploy/deploy.sh` you can find functions like `use_binance_testnet()` or `use_rinkeby`. Add similar `use_<chain>` functions for the chains you need to deploy to.

At this point, you only need these functions to have correct URL, CMD, CHAIN_ID, addresses of not-yet-deployed contracts can be omitted.

Next, at the end of the file, add:

```bash
use_rinkeby # or other chain
$CMD deploy --all --chainId $CHAIN_ID --relayerThreshold 1 --config true --relayers 0xfD62e4680Df904Eb3afBC4c98c50771eA231D77A
```

And run the `deploy.sh` file:
```bash
cd deploy
./deploy.sh
```

Don't forget to save the config somewhere, and modify BRIDGE_ADDR, ERC20_HANDLER_ADDR, ERC721_HANDLER_ADDR, GENERIC_HANDLER_ADDR variables in the `use_rinkeby` function!

## Add resouces

Once you have your functions set up, add something like this to the end of the file:
```bash
add_resource "use_binance_testnet" "use_rinkeby" 0x4E304b8376904B294CF713425A966dd4c44c0369 "BT2"
```
The first parameter to `add_resource` is the name of the function to use original chain, the one that already has the token.
The second parameter is the name of the function to use the other chain, in which the corresponding token will be deployed.
The third parameter is the address of the original token in the original chain.
The fourth parameter is the symbol with which the corresponding token will be deployed.

This command will deploy token, create resource ids, add resources to both chains.

I think it's best to save all the output in the file somewhere, but what you really need is the last several lines of the output that look like this:
```
Original token on use_binance_testnt: 0x4E304b8376904B294CF713425A966dd4c44c0369
Corresponding token on use_rinkeby: 0x21441C83F5C097934694f433f63dE0aDf955Caf2
RES_ID 0x00000000000000000000004E304b8376904B294CF713425A966dd4c44c036903
RES_ID_IN_OTHER_CHAIN 0x000000000000000000000021441C83F5C097934694f433f63dE0aDf955Caf201
```

After running these command, check the bridge contracts on block explorer to see if all the transactions didn't fail.
