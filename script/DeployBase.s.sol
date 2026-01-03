// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {BasedFusaka} from "../src/BasedFusaka.sol";

contract DeployBase is Script {
    function run() external {
        // Base mainnet RPC: https://mainnet.base.org
        // Chain ID: 8453

        // Configuration
        uint256 initialSupply = 1000000; // 1M tokens (adjust as needed)

        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        BasedFusaka token = new BasedFusaka(initialSupply);

        // Log deployment info
        console.log("BasedFusaka deployed to:", address(token));
        console.log("Owner:", token.owner());
        console.log("Total Supply:", token.totalSupply());
        console.log("Name:", token.name());
        console.log("Symbol:", token.symbol());

        vm.stopBroadcast();
    }
}