// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract ExampleGA2 {
    function opaquePredicate(uint256 x) public pure returns (uint256) {
        if (x > 1) {
            if (x > 0) {
                return x;
            }
        }
    }
}
