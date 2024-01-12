// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract VotingInstance {
    string public voteSubject;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    mapping(address => bool) public voters;
    mapping(uint256 => Candidate) public candidates;

    uint256 public candidatesCount;

    constructor(string memory _voteSubject) {
        voteSubject = _voteSubject;
    }

    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint256 _candidateId) public {
        require(!voters[msg.sender], "You have already voted.");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate to vote for.");
        voters[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        emit votedEvent(_candidateId);
    }

    event votedEvent(uint256 indexed _candidateId);
}
