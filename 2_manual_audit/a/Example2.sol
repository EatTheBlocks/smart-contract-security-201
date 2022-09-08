// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract Example2 {
    uint256 public param;

    function change(int256 p) external {
        param = uint256(p);
    }
}
