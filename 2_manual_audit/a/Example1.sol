// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Example1 is Ownable {
    using Address for address;

    // Parameters
    uint128 public constant ValidatorThreshold = 1 ether;
    uint32 public constant MinimumRequiredNumValidators = 4;

    // Properties
    address[] public _validators;
    mapping(address => bool) _addressToIsValidator;
    mapping(address => uint256) _addressToStakedAmount;
    mapping(address => uint256) _addressToValidatorIndex;
    uint256 _stakedAmount;

    // Modifiers
    modifier onlyEOA() {
        require(!msg.sender.isContract(), "Only EOA can call function");
        _;
    }

    modifier onlyStaker() {
        require(
            _addressToStakedAmount[msg.sender] > 0,
            "Only staker can call function"
        );
        _;
    }

    constructor() {}

    // View functions
    function stakedAmount() public view returns (uint256) {
        return _stakedAmount;
    }

    function validators() public view returns (address[] memory) {
        return _validators;
    }

    function isValidator(address addr) public view returns (bool) {
        return _addressToIsValidator[addr];
    }

    function accountStake(address addr) public view returns (uint256) {
        return _addressToStakedAmount[addr];
    }

    // Public functions
    receive() external payable {
        _stake();
    }

    function stake() public payable {
        _stake();
    }

    function unstake() external onlyStaker {
        _unstake();
    }

    function addValidator(address newValidator) public onlyOwner {
        _validators.push(newValidator);
    }

    // Private functions
    function _stake() private {
        _stakedAmount += msg.value;
        _addressToStakedAmount[msg.sender] = msg.value;

        if (
            _addressToIsValidator[msg.sender] &&
            _addressToStakedAmount[msg.sender] >= ValidatorThreshold
        ) {
            // append to validator set
            _addressToIsValidator[msg.sender] = true;
            _addressToValidatorIndex[msg.sender] = _validators.length;
            _validators.push(msg.sender);
        }
    }

    function _unstake() private {
        require(
            _validators.length > MinimumRequiredNumValidators,
            "access denied"
        );

        uint256 amount = _addressToStakedAmount[msg.sender];

        if (_addressToIsValidator[msg.sender]) {
            _deleteFromValidators(msg.sender);
        }

        payable(msg.sender).transfer(amount);
        _addressToStakedAmount[msg.sender] = 0;
        _stakedAmount -= amount;
    }

    function _deleteFromValidators(address staker) private {
        require(
            _addressToValidatorIndex[staker] < _validators.length,
            "index out of range"
        );

        // index of removed address
        uint256 index = _addressToValidatorIndex[staker];
        uint256 lastIndex = _validators.length - 1;

        if (index != lastIndex) {
            // exchange between the element and last to pop for delete
            address lastAddr = _validators[lastIndex];
            _validators[index] = lastAddr;
            _addressToValidatorIndex[lastAddr] = index;
        }

        _addressToIsValidator[staker] = false;
        _addressToValidatorIndex[staker] = 0;
        _validators.pop();
    }
}
