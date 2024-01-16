// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


interface EventInterface{
    event votedEvent(uint256 indexed pollId, address voter);
}