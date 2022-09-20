// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract ExampleCheckedUnchecked {
    function exampleChecked(uint8 a, uint8 b)
        public
        pure
        returns (uint256 value)
    {
        value = uint256(a) + b;
    }

    function exampleUnchecked(uint8 a, uint8 b)
        public
        pure
        returns (uint256 value)
    {
        unchecked {
            value = uint256(a) + b;
        }
    }
}
