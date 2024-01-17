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

    address[] users;
    address USER;

    function uintToString(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) {
            return "0";
        }
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + _value % 10));
            _value /= 10;
        }
        return string(buffer);
    }

    function setUp() external {
        DeployPollManager deployPollManager = new DeployPollManager();
        pollManager = deployPollManager.run();
        for (uint256 idx=0; idx < 5; idx++){
            address user = makeAddr(uintToString(idx)); 
            users.push(user);
            vm.deal(user, 10 ether);
        }
        USER = users[0];
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

    function __perform_vote() private{
        for (uint256 idx; idx < users.length; idx++){
                vm.prank(users[idx]);
                uint256 voteNumber;
                if(idx % 2 == 0){
                    voteNumber = 0;
                }else{
                    voteNumber = 1;
                }
                pollInstance.vote{value: .01 ether}(voteNumber);
            }
    }

    function testGetLeadingPollId() public{
        __perform_vote();
        uint256 leadingPollId = pollInstance.getLeadingPollId();
        assertEq(leadingPollId, 0);
    }

    // function testPayoutWinners() public{
    //       __perform_vote();
    //       pollInstance.payoutWinners();
    //       uint256 leadingPollId = pollInstance.getLeadingPollId();
    // }

}