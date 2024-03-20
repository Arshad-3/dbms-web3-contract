// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AssetToken is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    constructor(address initialOwner)
        ERC721("AssetToken", "ToA")
        Ownable(initialOwner)
    {}

    struct Owner {
        address add;
        uint256 amount;
    }
    struct NFT{
        uint256 totalShares;
        Owner[] owners;
    }
    mapping(uint256 => NFT) public nft;
    uint256 public _totalShares;

    function _baseURI() internal pure override returns (string memory) {
        return "https://localhost:3000/";
    }

    function safeMint(address to, string memory uri, uint256 totalShares) public onlyOwner {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _totalShares = totalShares;
        nft[tokenId].owners.push(Owner(to,totalShares));
        nft[tokenId].totalShares = totalShares;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function buyShares(uint256 _tokenId, uint256 _amount, address from) external payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= _totalShares, "Not enough shares available");

        nft[_tokenId].owners.push(Owner(msg.sender, _amount));

        // Transfer ETH to contract owner (you may customize this logic)
        //payable(address(this)).transfer(msg.value);

        // Transfer NFT to the buyer
        //transferFrom(msg.sender, address(this), _tokenId);

        sellShares(_tokenId, _amount, from);
    }

    function sellShares(uint256 _tokenId, uint256 _amount, address from) public {
        uint256 i = getElementIndex(from,_tokenId);
        require( i < 100, "You don't own these shares");
        require( _amount <= nft[_tokenId].totalShares, "Not enough shares to sell");

        nft[_tokenId].owners[i].amount -= _amount;

        // Transfer NFT back to the seller
        //transferFrom(from, from, _tokenId);

        // Transfer ETH to the seller (you may customize this logic)
        //payable(msg.sender).transfer(_amount * (address(this).balance / _totalShares));
    }

    function getElementIndex(address _element, uint256 _tokenId) public view returns (uint256) {
        for (uint256 i = 0; i < nft[_tokenId].owners.length; i++) {
            if (nft[_tokenId].owners[i].add == _element) {
                return i; // Element found, return its index
            }
        }
        revert("Element not found"); // If element not found, revert
    }

    function getOwnershipDetails(uint256 _tokenId) external view returns (address[] memory owners, uint256[] memory amounts) {
        owners = new address[](nft[_tokenId].owners.length);
        amounts = new uint256[](nft[_tokenId].owners.length);

        for (uint256 i = 0; i < nft[_tokenId].owners.length; i++) {
            owners[i] = nft[_tokenId].owners[i].add;
            amounts[i] = nft[_tokenId].owners[i].amount;
        }

        return (owners, amounts);
    }
}
