// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/utils/Address.sol";

contract SimpleAuction {
    using Address for address payable;

    address payable public currentLeader;
    uint256 public currentBid;

    function bid() external payable {
        require(msg.value > currentBid, "Bid not high enough");
        address payable previousLeader = currentLeader;
        uint256 previousBid = currentBid;
        currentLeader = payable(msg.sender);
        currentBid = msg.value;
        previousLeader.sendValue(previousBid);
    }
}