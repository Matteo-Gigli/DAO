//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/Collection/NFT.sol";
import "contracts/Data/Data.sol";


pragma solidity >0.5.0 <0.9.0;

contract Marketplace is Ownable{

    Data data;

    constructor(){

    }


    function initDataContract(address dataContractAddress)public onlyOwner{
        data = Data(dataContractAddress);
    }



    function listingCollection(
        address collectionAddress,
        uint pricePerUnit,
        uint[]memory IDS
        )public{
            data.populateCollectionData(
                collectionAddress,
                msg.sender,
                pricePerUnit,
                IDS
                );

    }


    function removeCollection(address collectionAddress)public{
        data.delistCollection(collectionAddress, msg.sender);
    }




    function buyNft(address collectionAddress, uint tokenId)external payable{
        require(msg.sender != NFT(collectionAddress).owner(), "Not possible buy your own token!");
        require(msg.value == data.getUnitCollectionPrice(collectionAddress), "Set correct Price!");
        data.delistSingleItem(collectionAddress, tokenId);
        address tokenOwner = NFT(collectionAddress).ownerOf(tokenId);
        payable(tokenOwner).transfer(msg.value);
        NFT(collectionAddress).safeTransferFrom(tokenOwner, msg.sender, tokenId);

    }
}
