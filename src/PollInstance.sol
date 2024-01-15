// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { PriceConverter } from "./PriceConverter.sol";


contract PollInstance {
    
    //libs
    using PriceConverter for uint256;

    // vars
    string public voteSubject;
    uint256 public pollCount;

    // data structures
    mapping(address => bool) public voters;
    mapping(uint256 => PollOption) public pollOptions;

    struct PollOption {
        uint256 id;
        string option;
        uint256 voteCount;
        mapping(address => bool) voters;
    }

    // constants
    AggregatorV3Interface private s_priceFeed;
    // price to vote is $1.99
    uint256 public constant VOTE_PRICE_USD = 199e16;
    uint256 public immutable i_expirationDate;

    constructor(AggregatorV3Interface _priceFeed, string memory _voteSubject, uint256 expirationDate, string[] memory _pollOptions) {
        voteSubject = _voteSubject;
        s_priceFeed = _priceFeed;
        i_expirationDate = expirationDate;

        for (uint256 idx = 0; idx < _pollOptions.length; idx++){
            PollOption storage pollOption = pollOptions[idx];
            pollOption.id = idx;
            pollOption.option = _pollOptions[idx];
            pollOption.voteCount = 0;
            pollCount ++;
        }
    }

    function vote(uint256 _pollId) public payable{
        require(msg.value.getConversionRate(s_priceFeed) >= VOTE_PRICE_USD, "didnt send enough eth");
        require(!voters[msg.sender], "You have already voted.");
        PollOption storage pollOption = pollOptions[_pollId];
        require(_pollId <= pollCount, "Invalid poll option.");
        pollOption.voters[msg.sender] = true;
        voters[msg.sender] = true;
        pollOption.voteCount++;
        emit votedEvent(_pollId, msg.sender);
    }

    function getLeadingPoll() public view returns(memory PollOption){
        PollOption memory leadingPollOption;
        for (uint256 idx = 0; idx < pollCount; idx++){
            if(pollOptions[idx].voteCount > leadingPollOption.voteCount){
                leadingPollOption = pollOptions[idx];
            }
        }
        return leadingPollOption;
    }

    event votedEvent(uint256 indexed pollId, address voter);
}
