pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IResultOracle {
    function getRoundResult() external returns (uint32);
}

interface INFTCollection {
    function isOwnerOfThisNft(uint256 id, address sender)
        external
        view
        returns (bool);

    function mint(address owner, uint8 idTeam) external;

    function randomMint(address owner) external returns (uint16);

    function balanceOf(address user) external view returns (uint256);
}

contract Pool is Ownable {
    enum Phase {
        DEPOSITING,
        VOTING,
        UPDATING_RESULT,
        END
    }

    using Strings for uint256;

    mapping(uint16 => uint32) private _selection; //0 to 4294967295

    mapping(uint16 => uint256) private withdrawnAmount; 

    mapping(uint16 => bool) private _winners;

    uint16 public _amountRoundWinners; //they are 1600 y uint16 = 65535
    uint16 private _givenWhitelist;
    uint16 private _participants; //they are 1600 y uint16 = 65535
    uint8 public NFT_PRICE = 50;
    uint8 public NFT_WHITELISTED_PRICE = 30;
    uint256 public totalPrize;
    bool public thereIsAWinner;

    Phase public _currentPhase = Phase.DEPOSITING;

    IResultOracle private _resultOracle;
    IERC20 private _stablecoinToken;
    INFTCollection private _nftContract;

    mapping(address => bool) private _whitelist;

    constructor(
        IERC20 stablecoinToken,
        INFTCollection nftContract,
        IResultOracle resultOracle
    ) {
        _stablecoinToken = stablecoinToken;
        _nftContract = nftContract;
        _resultOracle = resultOracle;
    }

    //getters
    function getRoundVote(uint16 nftId) external view returns (uint32) {
        return _selection[nftId];
    }

    function amountToClaim(uint16 nftId) public view returns (uint256 amount) {
        require(
            _nftContract.isOwnerOfThisNft(nftId, msg.sender),
            "Owner does not own this nft."
        );
        uint256 totalRewards;
        if (_winners[nftId]) {
            totalRewards = ((totalPrize * 80) / 100) / _amountRoundWinners;
        }

        if (redistributeRewardsNoWinnerInRound()) {
            totalRewards += ((totalPrize * 80) / 100) / _amountRoundWinners;
        }

        amount = totalRewards - withdrawnAmount[nftId];
    }

    function getNFTPrice(address sender) public view returns (uint256) {
        if (_whitelist[sender] && _nftContract.balanceOf(sender) == 0) {
            return NFT_WHITELISTED_PRICE;
        }
        return NFT_PRICE;
    }

    //mutable methods

    //mint NFTS
    function buyRandomNFT() external {
        onlyPhase(Phase.DEPOSITING);
        uint256 price = getNFTPrice(msg.sender);

        //need to have allowance
        _stablecoinToken.transferFrom(msg.sender, address(this), price);
        uint16 nftId = _nftContract.randomMint(msg.sender);
        totalPrize = totalPrize + price;
        _participants++;

        emit minted(msg.sender, nftId);
    }

    //voting
    function vote(uint16 nftId, uint32 _vote) external {
        require(
            _nftContract.isOwnerOfThisNft(nftId, msg.sender),
            "msg.sender does not own this nft."
        );
        require(
            _vote <= 11111111,
            "Does not meet the characteristics of this vote."
        );
        require(_selection[nftId] == 0, "You already voted.");
        _selection[nftId] = _vote;

        emit voted(msg.sender);
    }

    //claim
    function claim(uint16 nftId) external returns (uint256) {
        uint256 amount = amountToClaim(nftId);

        withdrawnAmount[nftId] += amount;

        require(amount == 0, "Nothing to claim.");

        _stablecoinToken.transfer(msg.sender, amount);

        return amount;
    }

    //admin methods - change phase methods
    function endVotingTime() external onlyOwner {
        if (_currentPhase == Phase.VOTING || _currentPhase == Phase.DEPOSITING) {
            _currentPhase = Phase.UPDATING_RESULT;
        }
    }

    function updateRoundWinners() external onlyOwner {
        onlyPhase(Phase.UPDATING_RESULT);
        uint16 amountWinners;
        uint32 result = _resultOracle.getRoundResult();
        for (uint16 i; i <= _participants; i++) {
            if (isWinnerOfRound(i, uint256(result))) {
                _winners[i] = true;
                amountWinners += 1;
            }
        }
        _amountRoundWinners = amountWinners;
        _currentPhase = Phase.VOTING;
    }

    function isWinnerOfRound(uint16 nftId, uint256 result)
        private
        view
        returns (bool)
    {
        uint256 selection = uint256(_selection[nftId]);
        uint8 success;
        for (uint256 i; i < 8; i++) {
            if (bytes(selection.toString())[i] == bytes(result.toString())[i]) {
                success++;
            }
        }
        if (success > 4) return true;
        return false;
    }

    function redistributeRewardsNoWinnerInRound() internal view returns (bool) {
        if (_currentPhase == Phase.END && thereIsAWinner == false) {
            return true;
        } else {
            return false;
        }
    }

    function devTeamReceiveFunds() external onlyOwner {
        onlyPhase(Phase.END);
        uint256 amount = (totalPrize * 10) / 100; //10% of pool
        _stablecoinToken.transfer(owner(), amount);
    }

    //whitelist
    function addWhitelist() external {
        if (_givenWhitelist < 320) {
            _givenWhitelist++;
            _whitelist[msg.sender] = true;
        }
    }

    function onlyPhase(Phase expected) private view {
        require(
            _currentPhase == expected,
            "You can not perform this action in this phase."
        );
    }

    event claimed(address claimer, uint256 amount);
    event voted(address voter);
    event minted(address minter, uint16 nftId);
}
