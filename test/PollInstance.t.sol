// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";

import { DeployPollManager } from "../script/DeployPollManager.s.sol";
import { PollInstance, PollManager } from "../src/PollManager.sol";


contract PollInstanceTest is Test {

    PollManager pollManager;
    PollInstance pollInstance;
    
    string testSubject = "What is your favorite color";
    string[] pollOptions = ["blue", "green", "red"];
    uint256 expirationDate = 1;

    address USER = makeAddr("user");

    function setUp() external {
        DeployPollManager deployPollManager = new DeployPollManager();
        pollManager = deployPollManager.run();
        vm.deal(USER, 10 ether);
        vm.prank(USER);
        pollInstance = pollManager.createNewPollingInstance{value: .01 ether}(
            testSubject,
            expirationDate,
            pollOptions
        );
    }
    
    // test to ensure the subject is properly set
    function testPollInstanceSubject() public{
        assertEq(pollInstance.voteSubject(), testSubject);
    }

    // test to ensure the id is properly being set
    function testPollInstanceId() public{
        assertEq(pollInstance.pollInstanceId(), 0);
    }

    // test to ensure the manager address is set to the PollManager
    function testPollInstanceManager() public{
        assertEq(pollInstance.i_managerAddress(), address(pollManager));
    }

    // test to ensure the creator address is set the EOA creator of the PollInstance
    function testPollInstanceCreator() public{
        assertEq(pollInstance.i_creatorAddress(), address(USER));
    }

    // test that the poll options that are set in the constuction of the contract match the input
    function testPollOptionsSet() public {
        uint256 pollOptionCount = pollInstance.pollOptionCount();
        for (uint256 idx = 0; idx < pollOptionCount; idx++) {
            (uint256 actualId, string memory actualOption) = pollInstance.pollOptions(idx);
            assertEq(idx, actualId);
            assertEq(pollOptions[idx], actualOption);
        }
    }
    
    function testVote() public{}
    


}