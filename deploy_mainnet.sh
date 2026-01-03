#!/bin/bash

# Load environment variables
source .env

# Deploy BasedFusaka to Base mainnet
forge script script/DeployBase.s.sol \
  --rpc-url $BASE_MAINNET_RPC_URL \
  --account defaultKey \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY