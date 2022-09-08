// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract ExampleGB1 {
    function swapNumbers(uint256 a, uint256 b) external pure {
        // Declare a new variable;
        uint256 thirdVariable = a;

        // Swap variables
        a = b;
        b = thirdVariable;
    }

    function swapNumbersV2(uint256 a, uint256 b) external pure {
        // Swap variables
        (a, b) = (b, a);
    }
}
