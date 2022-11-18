//SPDX-License-Identifier: MIT


import "@openzeppelin/contracts/access/Ownable.sol";
import "./NFT.sol";


pragma solidity >0.5.0 <0.9.0;

contract Factory is Ownable{

    NFT[] public deployedCollectionAddress;

    constructor(){

    }


    function createCollection(
        string memory name,
        string memory symbol,
        string memory uri,
        uint maxSupply
        )public onlyOwner{
            NFT nft = new NFT(name, symbol, uri, maxSupply, msg.sender);
            deployedCollectionAddress.push(nft);
    }


}
