# DAO


<h2>📝 DAO Contract</h2>
<br>

<p><strong>I just created a DAO, attached to a NFT Marketplace.</strong></p>
<p><strong>Users can vote on a proposal Yes/No to buy NFTs.</strong></p>
<br>

<h2>🔍 Contracts Detail</h2>
<br>

<h3>💰 Factory.sol  &&  NFT.sol</h3>
<br>
<p><strong>Here we have a factory contract, where anyone can create his/her own collection just passing some parameters(name, symbol, uri and totalSupply).</strong></p>
<p><strong>Once the transaction it's called, we can retrieve the new NFT COllection Address from the  deployedCollectionAddress.</strong></p>
<p><strong>Remember, we have to pass index from 0, so the first collection deployed will be index 0.</strong></p>
<br>
<p><strong>NFT contract is a normal ERC721 Standard, the only thing to mentionate here is we need to pass the marketplace Address to initMarketplace function</strong></p>
<p><strong>This will create an instance of Marketplace contract</strong></p>
<br>


<h3>📊 Marketplace.sol   &&     Data.sol</h3>
<br>

<p><strong>This is the contract where we are going to list all the Collections</strong></p>
<p><strong>As before we have a function initDataContract() to initialize our Data contract.</strong></p>
<p><strong>We have funcion for listing, delisting and buy NFTs</strong></p>
<br>
<p><strong>Marketplace is strictly connected wit the Data.sol contract.</strong></p>
<p><strong>In fact Data is the contract where we store all the information about the Marketplace.</strong></p>
<p><strong>Even in this contract we have to initialize the  Marketplace address from the initMarketPlaceContract() function.</strong></p>



<h3>🌱 DAO.sol    &&     DAOToken.sol</h3>
<br>
<p><strong>DAO.sol is our DAO, where we can create proposal and vote Yes or No to the proposal</strong></p>
<p><strong>Even here we ha to initialize different contracts address like: Marketplace, DaoToken, Data.</strong></p>
<p><strong>We will use the function initMarketplace(), initDAOToken(), initData() to do that</strong></p>
<p><strong>In this contract there are some rules to follow like: Only users with more than 20 DaoTokens can create a proposal.</strong></p>
<p><strong>Only users with more than 1 DaoTokens can Vote, and obviously you can vote only once for every proposal.</strong></p>
<p><strong>We can buy DaoTokens from here at 0,01 price per 10 tokens.</strong></p>
<br>
<p><strong>DAOToken.sol is a simple ERC20 Token</strong></p>
<br>


<h2>🔧 Built With</h2>
<br>
<p><strong>Solidity, Hardhat</strong></p>
<p><strong></strong></p>
