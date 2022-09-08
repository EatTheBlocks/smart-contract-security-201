// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract ExampleGA3 {
    uint256 num = 0;

    function expensiveLoop(uint256 x) public {
        for (uint256 i = 0; i < x; i++) {
            num += 1;
        }
    }

    function lessExpensiveLoop(uint256 x) public {
        uint256 temp = num;
        for (uint256 i = 0; i < x; i++) {
            temp += 1;
        }
        num = temp;
    }
}
