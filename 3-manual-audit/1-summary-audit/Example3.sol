// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract StakingRewards {
    uint256 private imporantValue;
    address private admin;
    address private stakingToken;
    address private rewardsToken;


    constructor(address staking, address rewards) {
        admin = msg.sender;
        stakingToken = staking;
        rewardsToken = rewards;
    }

    function setImportantValue(uint256 newValue) external {
        require(msg.sender == admin, "you are not the admin");
        importantValue = newValue;
    }

    function setRewardsToken(address newToken) external {
        require(msg.sender == admin, "you are not the admin");
        rewardsToken = newToken;
    }

}