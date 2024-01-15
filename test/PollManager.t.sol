// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";

import { DeployPollManager } from "../script/DeployPollManager.s.sol";
import { PollInstance, PollManager } from "../src/PollManager.sol";


contract PollManagerTest is Test {

    PollManager pollManager;
    
    string[] pollOptions = ["blue", "green", "red"];

    address USER = makeAddr("user");


    function setUp() external {
        DeployPollManager deployPollManager = new DeployPollManager();
        pollManager = deployPollManager.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimumDollarIsFive() public {
        assertEq(pollManager.minimumPollCreationUsd(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(pollManager.owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = pollManager.getVersion();
        assertEq(version, 4);
    }

    function testCreatePollWithoutEnoughEth() public {
        vm.expectRevert();
        pollManager.createNewPollingInstance(
            "What is your favorite color",
            1,
            pollOptions
        );
    }

    function testCreatePoll() public {
        vm.prank(USER);
        pollManager.createNewPollingInstance{value: .01 ether}(
            "What is your favorite color",
            1,
            pollOptions
        );
    }

}