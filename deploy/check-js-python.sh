#!/bin/bash

set -e

RES=$(
python3 ./get_deployed_token_addr.py <<- ENDOFMESSAGE
Contract Addresses
================================================================
Bridge:             0x631218f02a64404759C432416E878d219706f00a
----------------------------------------------------------------
Erc20 Handler:      0x052288463bb878af95EB9783a9E2908bED6695ad
----------------------------------------------------------------
Erc721 Handler:     0xD939eE3a8B0072f86Ed4fe00A965ef2f14cb7aaE
----------------------------------------------------------------
Generic Handler:    0xD3927c9813125053C132c8f9D156098966052e2a
----------------------------------------------------------------
Erc20:              0xbDbd683D1Df7d015C5cb74315744d4229ee1c103
----------------------------------------------------------------
Erc721:             0xf41bD9A78a54704b371C1DAA23323cf48E39dE34
----------------------------------------------------------------
Centrifuge Asset:   Not Deployed
----------------------------------------------------------------
WETC:               Not Deployed
================================================================
ENDOFMESSAGE
)

if [ "$RES" != "0xbDbd683D1Df7d015C5cb74315744d4229ee1c103" ]; then
    echo "ERROR: Problem with python3";
    exit 1;
fi


RES=$(node make_resource_id.js 0xbDbd683D1Df7d015C5cb74315744d4229ee1c103 1)

if [ "$RES" != "0x0000000000000000000000bDbd683D1Df7d015C5cb74315744d4229ee1c10301" ]; then
    echo "ERROR: Problem with node js";
    exit 1;
fi


echo "Nodejs and python3 seem to work"
