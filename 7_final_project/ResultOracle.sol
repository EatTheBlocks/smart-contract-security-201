pragma solidity ^0.8.5;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract ResultOracle is Ownable {
    address[] private _judges = new address[](3);
    uint256 private constant NUMBER_OF_JUDGES = 3;

    uint32 private _roundResult = type(uint32).max;

    uint32[] public _roundDebate = [
        type(uint32).max,
        type(uint32).max,
        type(uint32).max
    ];

    constructor(address[] memory judges) {
        require(judges.length == NUMBER_OF_JUDGES, "You must set 3 judges.");
        for (uint8 i; i < _judges.length; i++) {
            require(judges[i] != address(0), "Address zero can't be a judge.");
            require(judges[i] != msg.sender, "The owner can't be a judge.");
            require(
                !isJudge(judges[i]),
                "You can't set the same address twice as a judge."
            );
            _judges[i] = judges[i];
        }
    }

    function getRoundResult() external view returns (uint32) {
        require(_roundResult == type(uint32).max, "There is no result yet.");
        return _roundResult;
    }

    function getJudge(uint8 index) external view returns (address) {
        return _judges[index];
    }

    function getAmountOfJudge() public view returns (uint256) {
        return _judges.length;
    }

    function setNewJudge(uint8 index, address newJudge) external onlyOwner {
        require(index < NUMBER_OF_JUDGES, "Incorrect index.");
        require(newJudge != address(0), "A judge can't be address zero.");
        require(newJudge != msg.sender, "The owner can't be the judge.");
        require(!isJudge(newJudge), "Incorrect.");
        _judges[index] = newJudge;
    }

    //add judge debate
    function addJudgeDebateToRound(uint32 vote) external {
        require(vote <= 11111111, "Incorrect vote.");
        _roundDebate[getJudgeIndex(msg.sender)] = vote;
    }

    //set final vote
    function setRoundResult(uint32 vote) external onlyOwner returns (bool) {
        require(vote <= 11111111, "Incorrect vote.");
        require(
            judgesAddedRoundResults(),
            "The judges did not upload round results."
        );
        bool wasSet;
        for (uint256 i; i < _judges.length; i++) {
            uint8 flat;
            for (uint256 j; j < _judges.length; j++) {
                if (j != i && _roundDebate[i] == _roundDebate[j]) {
                    flat++;
                }
            }

            if (flat == 2 || (flat == 1 && _roundDebate[i] == vote)) {
                _roundResult = _roundDebate[i];
                wasSet = true;
            }
        }
        return false;
    }

    function judgesAddedRoundResults() private view returns (bool) {
        uint8 resultsAmounts;
        for (uint8 i; i < _roundDebate.length; i++) {
            if (_roundDebate[i] != type(uint32).max) {
                resultsAmounts++;
            }
        }
        if (resultsAmounts > 2) return true;
        return false;
    }

    //boolean is judge
    function getJudgeIndex(address aspirant) public view returns (uint8) {
        for (uint8 i = 0; i < _judges.length; i++) {
            if (_judges[i] == aspirant) {
                return i;
            }
        }
        revert("Is not a judge.");
    }

    function isJudge(address aspirant) private view returns (bool) {
        if (aspirant == _judges[0]) return true;
        if (aspirant == _judges[1]) return true;
        if (aspirant == _judges[2]) return true;
        return false;
    }
}
