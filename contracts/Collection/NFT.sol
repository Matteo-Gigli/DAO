//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "contracts/Marketplace/Marketplace.sol";


pragma solidity >0.5.0 <0.9.0;


contract NFT is ERC721, Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public collectionUri;
    uint public maxSupplyCollection;
    mapping(address=>uint) private _balances;

    Marketplace marketplace;

    error maxSupplyReached();

    constructor(
        string memory name,
        string memory symbol,
        string memory uri,
        uint totalAmount,
        address sender
        )ERC721(name, symbol){
            _transferOwnership(sender);
            collectionUri = string(abi.encodePacked(uri, "/"));
            maxSupplyCollection = totalAmount;

    }



    function initMarketplace(address marketplaceAddress)public onlyOwner{
        marketplace = Marketplace(marketplaceAddress);
    }



    function setNewUri(string memory newUri)public onlyOwner{
        collectionUri = string(abi.encodePacked(newUri, "/"));
    }



    function _baseURI() internal view virtual override returns (string memory) {
        return collectionUri;
    }



    function tokenURI(uint256 _tokenId) public override view returns (string memory) {
        string memory tokenId = Strings.toString(_tokenId);
        string memory uri = string(abi.encodePacked(_baseURI(), tokenId, ".json"));
        return uri;
    }



    function balanceOf(address account)public virtual view override returns(uint){
        return _balances[account];
    }



    function isApprovedForAll(address owner, address operator)public view virtual override returns (bool){
        return super.isApprovedForAll(owner, operator) || operator == address(marketplace);
    }



    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _balances[from] -= 1;
        _balances[to] +=1;
        super._transfer(from, to, tokenId);
    }


    function mintAllYourTokens()public onlyOwner{
        for(uint i = 0; i < maxSupplyCollection; ++i){
            uint newId = _tokenIds.current();
            if(newId < maxSupplyCollection){
                _safeMint(msg.sender, newId);
                _tokenIds.increment();
            }else{
                revert maxSupplyReached();
            }
        }
        _balances[msg.sender] += maxSupplyCollection;
    }
}