pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IPool {
    function isOwnerOfThisNft(uint256 id, address sender)
        external
        returns (bool);
}

contract CPERC1155 is ERC1155Supply {
    uint256 private tokenId;
    string[] private _hashIpfs;

    IPool private _poolContract;

    constructor(string[] memory hashes) ERC1155("https://ipfs.io/ipfs/{id}") {
        _hashIpfs = hashes;
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked("https://ipfs.io/ipfs/", _hashIpfs[id]));
    }

    function tokenMinted() external view returns (uint256) {
        return tokenId;
    }

    function randomMint(address owner) external returns (bool) {
        onlyPool();
        for (uint16 i; i < type(uint16).max; i++) {
            uint256 randomNftId = randomNumber();
            if (totalSupply(randomNftId) < 101) {
                _mint(owner, randomNftId, 1, "");
            }
        }
        return true;
    }

    function onlyPool() private view {
        require(msg.sender == address(_poolContract), "only Pool");
    }

    function randomNumber() private view returns (uint256 answer) {
        answer =
            uint256(
                keccak256(abi.encodePacked(block.timestamp, "asd", tokenId))
            ) %
            16;
    }
}
