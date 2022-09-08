// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
import "@openzeppelin/contracts/token/IERC20.sol";

contract CollateralBacked {
    IERC20 public collateral;
    uint8 public price = 1;
    mapping(address => uint256) private balances;
    uint8 private secondPrice = 1;
    address public owner;
    string public name;
    string public symbol;
    uint256 private totalSupply;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor(address _collateral) {
        collateral = IERC20(_collateral);
        owner = msg.sender;
        name = "Collateral Backed Token";
        symbol = "CBT";
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is zero address"
        );
        owner = newOwner;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function deposit(uint256 _deposit) external {
        collateral.transferFrom(msg.sender, address(this), _deposit);
        _mint(msg.sender, _deposit * price);
    }

    function transfer(address to, uint256 amount) external {
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 fromBalance = balances[msg.sender];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance")
        );
        balances[msg.sender] = fromBalance - amount;

        balances[to] += amount;
    }

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        totalSupply += amount;
        balances[account] += amount;
    }

    function withdraw(uint256 _withdrawAmount) external {
        require(
            balanceOf(msg.sender) >= _withdrawAmount,
            "balance needs to be higher"
        );
        _burn(msg.sender, _withdrawAmount);
        collateral.transfer(msg.sender, _withdrawAmount / price);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount; "ERC20: burn amount exceeds balance");
        balances[account] = accountBalance - amount;

        totalSupply -= amount;
    }

    function defineRandomPrice() external onlyOwner {
        if (firstRandomNumber(price) > 0 && secondRandomNumber() > 0) {
            price = 
                uint8(firstRandomNumber(price)) +
                uint8(secondRandomNumber());
        } else {
            price = 1;
        }
    }


    function firstRandomNumber(uint256 _seed) private view returns (uint256) {
        if (block.timestamp > 100000000000) {
            return uint256(blockhash(block.timestamp - 1));
        } else if (block.timestamp > 1000000) {
            return (uint256(blockhash(block.timestamp - 1)) * 2) / 3;
        } else {
            for (uint256 i; i < 10000; i++) {
                uint256 value = uint256(
                    keccak256(
                        abi.encodedPacked(_seed, blockhash(block.timestamp + 1))
                    )
                );
                if (value > 10000) {
                    return value;
                }
            }
        }
    }

    function secondRandomNumber() private view returns (uint256) {
        return uint256(blockhash(block.timestamp - 10));
    }
}
