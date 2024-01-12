// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {VotingInstance} from "./VotingInstance.sol";

contract VotingManager {
    address private owner;

    uint256 public votingInstanceCount;

    VotingInstance[] votingInstances;

    constructor() {
        owner = msg.sender;
    }

    function createNewVotingInstance(string memory _subject) public {
        votingInstances.push(new VotingInstance(_subject));
        votingInstanceCount++;
    }
}
