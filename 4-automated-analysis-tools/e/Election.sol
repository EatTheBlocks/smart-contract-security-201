// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.0;

contract Election {

    address public king;
    address public president;
    uint256 totalVotes;
    mapping(address => uint256) numberOfVotes;
    mapping(address => address) whoDidYouVote; 

    
    constructor() {
        king = msg.sender;
    }

    function vote(address candidate) public {
   
        if (whoDidYouVote[msg.sender] != address(0x0)) {
            numberOfVotes[whoDidYouVote[msg.sender]] -= 1;
            totalVotes -= 1;
        }
        numberOfVotes[candidate] += 1;
        whoDidYouVote[msg.sender] = candidate;
        if (numberOfVotes[candidate] > numberOfVotes[president]) {
            president = candidate;
        }        
        totalVotes += 1;

    }

    function miCandidate() public view returns (address) {
        address candidate = whoDidYouVote[msg.sender];
        return candidate;
    }

    function getNumberOfVotes(address candidate) public view returns (uint256) {
        return numberOfVotes[candidate];
    }


    function getVotePercentage(address candidate) public view returns (uint256) {
        return (numberOfVotes[candidate] / totalVotes) * 100;
    }


    function overturnElection() public{
        selfdestruct(msg.sender);
    }

}
