// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";

contract Vault {
    using Address for address payable;

    mapping(address => uint256) public balanceOf;

    function deposit() external payable{
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() external {
        require(balanceOf[msg.sender] > 0, "Nothing to withdraw");
        payable(msg.sender).sendValue(balanceOf[msg.sender]);
        balanceOf[msg.sender] = 0;
    }

}