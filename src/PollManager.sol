// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { PriceConverter } from "./PriceConverter.sol";
import { PollInstance } from "./PollInstance.sol";


// create a polling system
// allow users to vote
// winners on the winning outcome make some money
// create a leaderboard of polls


contract PollManager {

    //libs
    using PriceConverter for uint256;

    // vars
    address public owner;
    uint256 public pollingInstanceCount;

    // data structures
    mapping(uint256 => PollInstance) public pollingInstances;
    mapping(string => PollInstance) public pollingInstancesBySubject;
    
    // constants
    AggregatorV3Interface private s_priceFeed;
    uint256 public minimumPollCreationUsd;

    constructor(uint256 _minimumPollCreationUsd, address _aggregatorV3Address) {
        owner = msg.sender;
        minimumPollCreationUsd = _minimumPollCreationUsd;
        s_priceFeed = AggregatorV3Interface(_aggregatorV3Address);
    }

    function getVersion() public view returns (uint256){
        return s_priceFeed.version();
    }

    function createNewPollingInstance(string calldata _pollSubject, uint256 _expirationDate, string[] memory pollOptions) public payable returns (PollInstance){
        require(msg.value.getConversionRate(s_priceFeed) >= minimumPollCreationUsd, "didnt send enough eth");
        require(pollOptions.length <= 4, "Poll options must not be longer than 4");
        PollInstance pollingInstance = new PollInstance(s_priceFeed, _pollSubject, _expirationDate, pollOptions, msg.sender, pollingInstanceCount);
        pollingInstances[pollingInstanceCount] = pollingInstance;
        pollingInstancesBySubject[_pollSubject] = pollingInstance;
        pollingInstanceCount++;
        return pollingInstance;
    }


    // owner functions

    function withdraw() public onlyOwner{
        (bool callSuccess, ) = payable(owner).call{value: address(this).balance}("");
        require(callSuccess, "Call Failed");
    }

    function changeOwner(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }

    function setPriceFeed(address _contractAddress) public onlyOwner{
        s_priceFeed = AggregatorV3Interface(_contractAddress);
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }
}
