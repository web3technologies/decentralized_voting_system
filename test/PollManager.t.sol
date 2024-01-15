// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";

import { DeployPollManager } from "../script/DeployPollManager.s.sol";
import { PollInstance, PollManager } from "../src/PollManager.sol";


contract PollManagerTest is Test {

    PollManager pollManager;

    function setUp() external {
        DeployPollManager deployPollManager = new DeployPollManager();
        pollManager = deployPollManager.run();
    }

    function testMinimumDollarIsFive() public {
        assertEq(pollManager.minimumPollCreationUsd(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(pollManager.owner(), msg.sender);
    }

    // must use the --fork-url
    // function testPriceFeedVersionIsAccurate() public {
    //     uint256 version = pollManager.getVersion();
    //     assertEq(version, 4);
    // }

}