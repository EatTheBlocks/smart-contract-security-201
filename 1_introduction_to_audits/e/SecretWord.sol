// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";

contract SecretWord {

    using Address for address payable;

    bytes32 public constant hash = 0x3667a8ff1c31b7e3cc4f77a6f1042620a78ced51944f9512440c474937a4e99e;

    function solve(string memory solution) public {
        require(hash == keccak256(abi.encodePacked(solution)), "Incorrect answer");
        payable(msg.sender).sendValue(100 ether);
    }


    receive() external payable {} // This was not included in the video. It is necessary for you to be able to transfer ether to the contract. Make sure to transfer >=100 ether to this contract from other accounts before solving with "ETBsecurity201".

}


