// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";

import { PollManager } from "../src/PollManager.sol";
import { HelperConfig } from "./HelperConfig.s.sol";


contract DeployPollManager is Script {

    uint256 public constant POLL_CREATION_USD_PRICE = 5e18;

    function run() external returns(PollManager){

        HelperConfig helperConfig = new HelperConfig();
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig();
        // start of real transaction
        vm.startBroadcast();
        PollManager pollManager = new PollManager(POLL_CREATION_USD_PRICE, ethUsdPriceFeed);
        vm.stopBroadcast();

        return pollManager;
    }

}