const{expect} = require("chai");
const{expectRevert} = require("@openzeppelin/test-helpers");


describe("Testing Contracts Functionality", function(){


    let Factory, factory, NFT, DAO, dao, DAOToken,
        daoToken, Data, data, Marketplace, marketplace, owner, account2, account3;


    before(async()=>{
        Factory = await ethers.getContractFactory("Factory");
        factory = await Factory.deploy();
        await factory.deployed();


        DAO = await ethers.getContractFactory("DAO");
        dao = await DAO.deploy();
        await dao.deployed();


        DAOToken = await ethers.getContractFactory("DAOToken");
        daoToken = await DAOToken.deploy("DOAToken", "DTT", "1000000000000000000000");
        await daoToken.deployed();


        Marketplace = await ethers.getContractFactory("Marketplace");
        marketplace = await Marketplace.deploy();
        await marketplace.deployed();


        Data = await ethers.getContractFactory("Data");
        data = await Data.deploy();
        await data.deployed();

        [owner, account2, account3] = await ethers.getSigners();


        //Init Different Contracts:

        //Dao Initialize
        await dao.initMarketplace(marketplace.address);
        await dao.initDAOToken(daoToken.address);
        await dao.initData(data.address);


        //Data Initialize
        await data.initMarketPlaceContract(marketplace.address);


        //Marketplace Initialize
        await marketplace.initDataContract(data.address);


        await factory.createCollection("Collection", "CLL", "svdasvdasjhaj", 10);

        let takeAddressCollection = await factory.deployedCollectionAddress(0);
        console.log(takeAddressCollection);


        NFT = await hre.ethers.getContractAt("NFT", takeAddressCollection);

        await NFT.initMarketplace(marketplace.address);


    });


    it("should be able to mint all the tokens", async()=>{
       await NFT.mintAllYourTokens();
       let ownerTokenBalance = await NFT.balanceOf(owner.address);
       expect(ownerTokenBalance).to.be.equal(10);
       console.log("Token Owner Balance: ", ownerTokenBalance.toString());
    });


    it("should be reverted if listings is not coming from the owner of the collection", async()=>{
        let takeAddressCollection = await factory.deployedCollectionAddress(0);
        expectRevert(await marketplace.connect(account2).listingCollection(takeAddressCollection, "1000000000000000000", [0,1,2,3,4,5,6,7,8,9]),
             "");
    });



    it("should be able to list tokens on marketplace", async()=>{
        let takeAddressCollection = await factory.deployedCollectionAddress(0);

                                                                    //1*10*16
        await marketplace.listingCollection(takeAddressCollection, "10000000000000000", [0,1,2,3,4,5,6,7,8,9]);
        let tokenInMarketplace = await data.listingIdStatus(3);
        expect(tokenInMarketplace).to.be.equal(true);

    });


    it("should be able to delist collection if you are the owner of all the tokensID", async()=> {
        let takeAddressCollection = await factory.deployedCollectionAddress(0);
        await marketplace.connect(owner).removeCollection(takeAddressCollection);
        let tokenInMarketplace = await data.listingIdStatus(3);
        expect(tokenInMarketplace).to.be.equal(false);
    });



    // Relisting of Collection
    it("should be able to list tokens on marketplace", async()=>{
        let takeAddressCollection = await factory.deployedCollectionAddress(0);
        await marketplace.listingCollection(takeAddressCollection, "10000000000000000", [0,1,2,3,4,5,6,7,8,9]);
        let tokenInMarketplace = await data.listingIdStatus(3);
        expect(tokenInMarketplace).to.be.equal(true);
    });


    it("should be able to buy some DAOTokens to create a proposal (Min 20*10**18)", async()=>{
        //We repeat .buyDAOTokens 2 times because everytime with 0.01 ether we will receive
        //10*10**18 DAOTokens.
        //So if we want to create a proposal we need of 20*10**18 daoTokens.

        await dao.connect(account2).buyDAOTokens({value: "10000000000000000"});
        await dao.connect(account2).buyDAOTokens({value: "10000000000000000"});
        let account2BalanceOfDaoToken = await daoToken.balanceOf(account2.address);
        expect(account2BalanceOfDaoToken).to.be.equal("20000000000000000000");
    })



    it("should be able to create a Proposal to buy nft on Marketplace", async()=>{
        let takeAddressCollection = await factory.deployedCollectionAddress(0);
        await dao.connect(account2).createProposalToBuy(takeAddressCollection, 2, 1668759841);
        let proposal = await dao.proposalDetails(1);
        let proposalPrice = await proposal.price;
        expect(proposalPrice).to.be.equal("10000000000000000");
    });



    it("should be able to buy some DAO Tokens and make a vote", async()=>{
         await dao.connect(account3).buyDAOTokens({value: "10000000000000000"});
         await dao.connect(account3).voteYesOnProposal(1);
         let account3Balance = await daoToken.balanceOf(account3.address);
         expect(account3Balance).to.be.equal("9000000000000000000");
         let maps = await dao.alreadyVote(account3.address, 1);
         expect(maps).to.be.equal(true);

    });



    it("should be able to buy the Token from the marketplace", async()=>{
        await dao.executeProposal(1);
        let DAOTokenBalance = await NFT.balanceOf(dao.address);
        expect(DAOTokenBalance).to.be.equal(1);
    })












})