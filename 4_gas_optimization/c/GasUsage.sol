// SPDX-License-Identifier: GLP-3.0

pragma solidity 0.8.7;

contract GasUsage {
    uint256 percentage = 30;
    uint256 price;
    
    function splitAmountToOwnerAndSeller(uint256 amount) external returns (uint256 amountForSender, uint256 amountForOwner) {
        amountForSender = (amount * (100 - percentage)) / 100;
        amountForOwner = (amount * percentage) / 100;
        price = amountForOwner;
    }

    function splitAmountToOwnerAndSellerV2(uint256 amount) external returns (uint256 amountForSender, uint256 amountForOwner) {
        uint256 ownerPercentage = percentage;
        amountForSender = (amount * (100 - ownerPercentage)) / 100;
        amountForOwner = (amount * ownerPercentage) / 100;
        price = amountForOwner;
    }

}