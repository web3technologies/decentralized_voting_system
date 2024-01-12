// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VotingInstance} from "./VotingInstance.sol";

contract VotingManager {
    address private owner;

    uint256 public votingInstanceCount;

    VotingInstance[] public votingInstances;

    struct VotingObject{
        uint256 id;
        VotingInstance votingInstance;
    }

    constructor() {
        owner = msg.sender;
    }

    function createNewVotingInstance(string memory _subject) public returns (address){
        VotingInstance votingInstance = new VotingInstance(_subject);
        votingInstances.push(votingInstance);
        votingInstanceCount++;
        return address(votingInstance);
    }
}
