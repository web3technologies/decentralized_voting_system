// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";

import { DeployPollManager } from "../script/DeployPollManager.s.sol";
import { PollInstance, PollManager } from "../src/PollManager.sol";
import { EventInterface } from "../src/eventInterface.sol";


contract PollInstanceTest is Test, EventInterface {

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
        assertEq(pollOptionCount, pollOptions.length);
        for (uint256 idx = 0; idx < pollOptionCount; idx++) {
            (uint256 actualId, string memory actualOption) = pollInstance.pollOptions(idx);
            assertEq(idx, actualId);
            assertEq(pollOptions[idx], actualOption);
        }
    }
    
    // test that the voting is successful
    function testVoteSuccess() public{
        uint256 voteOptionId = 1;
        vm.prank(USER);
        pollInstance.vote{value: .01 ether}(voteOptionId);
        // address[] memory voters = pollInstance.pollVoters(voteOptionId);
        // assertEq(voter,address(USER));
        assertEq(pollInstance.voters(address(USER)), true);
        assertEq(pollInstance.voteCount(), voteOptionId);
        assertEq(address(pollInstance).balance, .01 ether);
    }

    // test that the vote reverts because not enough ether sent
    function testVoteDidNotSendEnoughEther() public{
        uint256 voteOptionId = 1;
        vm.prank(USER);
        vm.expectRevert();
        pollInstance.vote{value: .00001 ether}(voteOptionId);
    }

    // test that the vote because user has already voted
    function testVoteAlreadyVoted() public{
        uint256 voteOptionId = 1;
        vm.prank(USER);
        pollInstance.vote{value: .01 ether}(voteOptionId);
        vm.prank(USER);
        vm.expectRevert();
        pollInstance.vote{value: .01 ether}(voteOptionId);
        
    }

    // test that the option id does not exist
    function testVoteInvalidVoteOption() public{
        uint256 invalidVoteOptionId = 3;
        vm.prank(USER);
        vm.expectRevert();
        pollInstance.vote{value: .01 ether}(invalidVoteOptionId);
    }

}