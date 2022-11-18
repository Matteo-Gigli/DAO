//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "contracts/Collection/NFT.sol";
import "contracts/Marketplace/Marketplace.sol";
import "contracts/Data/Data.sol";
import "./DAOToken.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";


pragma solidity >0.5.0 <0.9.0;


contract DAO is Ownable, ERC721Holder{
    using Counters for Counters.Counter;
    Counters.Counter private _proposalId;


    Marketplace marketplace;
    DAOToken daoToken;
    Data data;


    struct ProposalCollection{
        address collectionAddress;
        uint tokenId;
        uint price;
        uint voteYes;
        uint voteNo;
        uint timeline;
    }

    mapping(uint=>ProposalCollection) public proposalDetails;
    mapping(address=>mapping(uint=>bool)) public alreadyVote;

    error setRightAmount();
    error noEnoughDAOTokenToCreateProposal();
    error FaucetEmptyOrOwnerCaller();
    error setCorrectPrice();
    error SomeReason();



    constructor(){

    }


    function initMarketplace(address marketPlaceAddress)public onlyOwner{
        marketplace = Marketplace(marketPlaceAddress);
    }


    function initDAOToken(address daoTokenAddress)public onlyOwner{
        daoToken = DAOToken(daoTokenAddress);
        uint daoContractBalance = daoToken.balanceOf(address(daoToken));
        daoToken.increaseAllowance(address(this), daoContractBalance);
    }




    function initData(address dataAddress)public onlyOwner{
        data = Data(dataAddress);
    }



    function buyDAOTokens()external payable{
        uint amountToSend = 10*10**18;
        if(msg.value == 0.01 ether){
            if(daoToken.balanceOf(address(daoToken)) > amountToSend && msg.sender != owner()){
                daoToken.transferFrom(address(daoToken), msg.sender, amountToSend);
            }else{
                revert FaucetEmptyOrOwnerCaller();
            }
        }else{
            revert setCorrectPrice();
        }
    }




    function createProposalToBuy(
        address collectionAddress,
        uint tokenId,
        uint deadline
        )public{
            uint proposalPrice = data.getUnitCollectionPrice(collectionAddress);

            if(daoToken.balanceOf(msg.sender) >= 20*10**18){
                _proposalId.increment();
                uint newProposal = _proposalId.current();
                proposalDetails[newProposal] = ProposalCollection(
                    collectionAddress,
                    tokenId,
                    proposalPrice,
                    0,
                    0,
                    deadline
                );
            }else{
                revert noEnoughDAOTokenToCreateProposal();
            }
        }


    //DA CONTROLLARE LO SPOSTAMENTO DI ALREADY VOTE E IL TIMESTAMP
    function voteYesOnProposal(uint proposalId)public{
        if(
            daoToken.balanceOf(msg.sender) > 1*10**18 &&
            alreadyVote[msg.sender][proposalId] == false &&
            block.timestamp <= proposalDetails[proposalId].timeline
            ){
                alreadyVote[msg.sender][proposalId] = true;
                proposalDetails[proposalId].voteYes += 1;
                daoToken.burn(msg.sender, 1*10**18);
        }else{
            revert SomeReason();
        }

    }


    //DA CONTROLLARE LO SPOSTAMENTO DI ALREADY VOTE E IL TIMESTAMP
    function voteNoOnProposal(uint proposalId)public{
        if(
            daoToken.balanceOf(msg.sender) > 1*10**18 &&
            alreadyVote[msg.sender][proposalId] == false &&
            block.timestamp <= proposalDetails[proposalId].timeline
            ){
                proposalDetails[proposalId].voteNo += 1;
                daoToken.burn(msg.sender, 1*10**18);
                alreadyVote[msg.sender][proposalId] = true;
        }else{
            revert SomeReason();
        }

    }




    function executeProposal(uint proposalId)public{
        uint proposalDeadline =  proposalDetails[proposalId].timeline;
        uint proposalYes = proposalDetails[proposalId].voteYes;
        uint proposalNo = proposalDetails[proposalId].voteNo;
        uint tokenId = proposalDetails[proposalId].tokenId;
        address collectionAddress = proposalDetails[proposalId].collectionAddress;
        uint tokenPrice = proposalDetails[proposalId].price;
        if(proposalDeadline > block.timestamp &&
            proposalYes > proposalNo
            ){
               marketplace.buyNft{value: tokenPrice}(collectionAddress, tokenId);
            }else{
                delete proposalDetails[proposalId];
            }
    }
}
