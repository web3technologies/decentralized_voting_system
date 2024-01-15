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
    uint256 public voteCount;

    // data structures
    mapping(address => bool) public voters;
    mapping(uint256 => address[]) public pollVoters;
    mapping(uint256 => PollOption) public pollOptions;

    struct PollOption {
        uint256 id;
        string option;
    }

    // constants
    AggregatorV3Interface private s_priceFeed;
    // price to vote is $1.99
    uint256 public constant VOTE_PRICE_USD = 199e16;
    uint256 public immutable i_expirationDate;
    address public immutable i_managerAddress;
    address public immutable i_creatorAddress;

    constructor(
            AggregatorV3Interface _priceFeed, 
            string memory _voteSubject, 
            uint256 _expirationDate, 
            string[] memory _pollOptions,
            address _managerAddress,
            address _creatorAddress
        ) 
    {
        voteSubject = _voteSubject;
        s_priceFeed = _priceFeed;
        i_expirationDate = _expirationDate;
        i_managerAddress = _managerAddress;
        i_creatorAddress = _creatorAddress;

        for (uint256 idx = 0; idx < _pollOptions.length; idx++){
            PollOption storage pollOption = pollOptions[idx];
            pollOption.id = idx;
            pollOption.option = _pollOptions[idx];
            pollCount ++;
        }
    }

    function vote(uint256 _pollId) public payable{
        require(msg.value.getConversionRate(s_priceFeed) >= VOTE_PRICE_USD, "didnt send enough eth");
        require(!voters[msg.sender], "You have already voted.");
        require(_pollId <= pollCount, "Invalid poll option.");
        pollVoters[_pollId].push(msg.sender);
        voteCount ++;
        emit votedEvent(_pollId, msg.sender);
    }

    function getLeadingPollId() public view returns(uint256){
        uint256 leadingPollOptionId = 0;
        for (uint256 idx = 1; idx < pollCount; idx++){
            if (pollVoters[idx].length > pollVoters[leadingPollOptionId].length){
                leadingPollOptionId = idx;
            }
        }
        return leadingPollOptionId;
    }

    // todo add reentrancy guard and check for completion of time
    function payoutWinners() public payable {
        address[] memory winners = pollVoters[getLeadingPollId()];
        uint256 numberOfWinners = winners.length;
        require(numberOfWinners > 0, "No winners to payout");

        uint256 winningsPerWinner = (address(this).balance * 80) / 100 / numberOfWinners;
        uint256 staticPay = address(this).balance * 10 / 100;

        for (uint256 idx = 0; idx < numberOfWinners; idx++){
            (bool callSuccess, ) = payable(winners[idx]).call{value: winningsPerWinner}("");
            require(callSuccess, "Call Failed");
        }
        (bool creatorSuccess, ) = payable(i_creatorAddress).call{value: staticPay}("");
        require(creatorSuccess, "Creator Call Failed");
        (bool managerSuccess, ) = payable(i_managerAddress).call{value: staticPay}("");
        require(managerSuccess, "Manager Call Failed");
    }

    event votedEvent(uint256 indexed pollId, address voter);
}
