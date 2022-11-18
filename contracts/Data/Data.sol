//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/Marketplace/Marketplace.sol";
import "contracts/Collection/NFT.sol";


pragma solidity >0.5.0 <0.9.0;

contract Data is Ownable{

    Marketplace marketplace;


    struct Collections{
        address creator;
        uint pricePerUnit;
        uint[] listedId;
    }

    mapping(address=>Collections)public collectionDetails;
    mapping(uint=>bool)public listingIdStatus;

    modifier onlyMarketplace(){
        msg.sender == address(marketplace);
        _;
    }

    error NoOwnerOfAllTheTokens(); 
    

    constructor(){

    }



    function initMarketPlaceContract(address marketPlaceAddress)public onlyOwner{
        marketplace = Marketplace(marketPlaceAddress);
    }


    function populateCollectionData(
        address collectionAddress, 
        address creator, 
        uint priceInWei,
        uint[] memory IDSToList
        )public onlyMarketplace{
            for(uint i = 0; i < IDSToList.length; ++i){
                if(creator == NFT(collectionAddress).ownerOf(IDSToList[i]) &&
                    listingIdStatus[IDSToList[i]] == false
                ){
                   collectionDetails[collectionAddress] = Collections(
                    creator, 
                    priceInWei,
                    IDSToList
                );
                listingIdStatus[IDSToList[i]] = true;
            } 
        }
    }


    function delistCollection(
        address collectionAddress, 
        address sender
        )public onlyMarketplace{
            uint[]memory IDS = collectionDetails[collectionAddress].listedId;
            for(uint i = 0; i<IDS.length; ++i){
                if(sender == NFT(collectionAddress).ownerOf(IDS[i])){
                    delete collectionDetails[collectionAddress];
                }else{
                    revert NoOwnerOfAllTheTokens();
                }

                listingIdStatus[IDS[i]] = false;
            }  
        }



    function getIndexTokenId(
        address collectionAddress,
        uint tokenId
        )internal view returns(uint _index){
            for(uint i = 0; i<collectionDetails[collectionAddress].listedId.length; ++i){
                if(
                    collectionDetails[collectionAddress].listedId[i] == tokenId){
                    _index = i;
                    return _index;
                } 
            }
        }



    function delistSingleItem(
        address collectionAddress, 
        uint tokenId
        )public onlyMarketplace{
            uint tokenIdIndex = getIndexTokenId(collectionAddress, tokenId);
            uint[]memory IDS = collectionDetails[collectionAddress].listedId;
            
            if(listingIdStatus[tokenId] == true){
                for(uint i = tokenIdIndex; i<IDS.length -1; ++i){
                    collectionDetails[collectionAddress].listedId[i] = collectionDetails[collectionAddress].listedId[i+1];   
                }
            }
            listingIdStatus[tokenId] = false;
            collectionDetails[collectionAddress].listedId.pop();        
    }



    function getUnitCollectionPrice(
        address collectionAddress
        )public view returns(uint){
            return collectionDetails[collectionAddress].pricePerUnit;
    }

}