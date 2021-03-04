#!/usr/bin/env bash

set -e

GAS_LIMIT=6721975
GAS_PRICE=1000000000

# admin private key, the one used to deploy contracts
PRIVATE_KEY=

use_binance_testnet() {
    GAS_PRICE=10000000000
    URL=https://data-seed-prebsc-1-s2.binance.org:8545
    CMD="cb-sol-cli --gasLimit $GAS_LIMIT --gasPrice $GAS_PRICE --networkId 97 --url $URL --privateKey $PRIVATE_KEY"
    CHAIN_ID=3

    # after running deploy_all, don't forget to modify these!
    BRIDGE_ADDR=0xfD0301Ff8B53860120eD19D847884EfFdDD0FD88
    ERC20_HANDLER_ADDR=0xEf0f18Bf7e3ddE04E9Cf38F8Bc786E0207A87455
    ERC721_HANDLER_ADDR=0xe45f254e5F461DeC9a863E84CcA9aFA7552B94C5
    GENERIC_HANDLER_ADDR=0x86B8484d24CCaa7870b9a8f32817a23d7d5a424F
}

use_rinkeby() {
    URL=https://rinkeby.infura.io/v3/97131c192c3645fa9ce01756e052e616
    CMD="cb-sol-cli --gasLimit $GAS_LIMIT --gasPrice $GAS_PRICE --networkId 4 --url $URL --privateKey $PRIVATE_KEY"
    CHAIN_ID=1

    # after running deploy_all, don't forget to modify these!
    BRIDGE_ADDR=0xc148a61CB324615F48854Ad5b87CfA2a21582D70
    ERC20_HANDLER_ADDR=0x3028d9d921A9cCF27266b47843Cb304109f867Df
    ERC721_HANDLER_ADDR=0xa70937884b6AE3684116aAA1Fe17e28A6742163D
    GENERIC_HANDLER_ADDR=0x4a39575e6c1eDc861Fda3cfC7001E5D961Cd443d
}

deploy_erc20() {
    $CMD deploy --erc20 --erc20Symbol "$1" --erc20Name "$1" | python3 get_deployed_token_addr.py
}

add_resource() {
    use_original_chain="$1"
    use_other_chain="$2"
    ERC20_TOKEN_ADDRESS=$3
    ERC20_DEPLOY_SYMBOL=$4

    echo "We take $ERC20_TOKEN_ADDRESS from $use_original_chain, and a new corresponding"
    echo "token with symbol $ERC20_DEPLOY_SYMBOL will be deployed on $use_other_chain"
    echo "Testing switching between networks:"
    $use_other_chain
    $use_original_chain
    echo "Gonna sleep for 20 seconds, take your time and check everything.."
    sleep 20

    # deploy token on other chain
    $use_other_chain
    OTHER_CHAIN_ERC20_ADDR=$(deploy_erc20 "$ERC20_DEPLOY_SYMBOL")

    # compute resource id
    $use_original_chain
    RES_ID=$(node make_resouce_id.js "$ERC20_TOKEN_ADDRESS" "$CHAIN_ID")
    $use_other_chain
    RES_ID_IN_OTHER_CHAIN=$(node make_resouce_id.js "$OTHER_CHAIN_ERC20_ADDR" "$CHAIN_ID")

    $use_original_chain
    $CMD bridge register-resource --bridge $BRIDGE_ADDR --handler $ERC20_HANDLER_ADDR --targetContract $ERC20_TOKEN_ADDRESS --resourceId $RES_ID
    $CMD bridge register-resource --bridge $BRIDGE_ADDR --handler $ERC20_HANDLER_ADDR --targetContract $ERC20_TOKEN_ADDRESS --resourceId $RES_ID_IN_OTHER_CHAIN

    $use_other_chain
    $CMD erc20 add-minter --erc20Address $OTHER_CHAIN_ERC20_ADDR --minter $ERC20_HANDLER_ADDR
    $CMD bridge register-resource --bridge $BRIDGE_ADDR --handler $ERC20_HANDLER_ADDR --targetContract $OTHER_CHAIN_ERC20_ADDR --resourceId $RES_ID
    $CMD bridge register-resource --bridge $BRIDGE_ADDR --handler $ERC20_HANDLER_ADDR --targetContract $OTHER_CHAIN_ERC20_ADDR --resourceId $RES_ID_IN_OTHER_CHAIN
    $CMD bridge set-burn --bridge $BRIDGE_ADDR --handler $ERC20_HANDLER_ADDR --tokenContract $OTHER_CHAIN_ERC20_ADDR

    echo "Original token on $use_original_chain: $ERC20_TOKEN_ADDRESS"
    echo "Corresponding token on $use_other_chain: $OTHER_CHAIN_ERC20_ADDR"
    echo "RES_ID=$RES_ID"
    echo "RES_ID_IN_OTHER_CHAIN=$RES_ID_IN_OTHER_CHAIN"
}

# HERE IS WHERE REAL COMMANDS START:

# add something here, don't forget to remove then
