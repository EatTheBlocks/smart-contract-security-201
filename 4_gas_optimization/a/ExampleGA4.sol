// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import {SafeMath} from "./SafeMath.sol";

contract SafeAddition {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256) {
        return SafeMath.add(a, b);
    }
}

contract SafeAddition2 {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Addition overflow");
        return c;
    }
}
