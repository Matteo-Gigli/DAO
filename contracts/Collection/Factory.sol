//SPDX-License-Identifier: MIT

import "./NFT.sol";

pragma solidity >0.5.0 <0.9.0;

contract Factory{

    NFT[] public deployedCollectionAddress;

    constructor(){

    }


    function createCollection(
        string memory name,
        string memory symbol,
        string memory uri,
        uint maxSupply
        )public{
            NFT nft = new NFT(name, symbol, uri, maxSupply, msg.sender);
            deployedCollectionAddress.push(nft);
    }


}
