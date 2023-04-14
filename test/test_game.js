const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

// Beasts
var beast0 = require("../Beasts/Beast_0.json");
var beast1 = require("../Beasts/Beast_1.json");
var beast2 = require("../Beasts/Beast_2.json");
var beast3 = require("../Beasts/Beast_3.json");
var beast4 = require("../Beasts/Beast_4.json");
var beast5 = require("../Beasts/Beast_5.json");
var beast6 = require("../Beasts/Beast_6.json");
var beast7 = require("../Beasts/Beast_7.json");
var beast8 = require("../Beasts/Beast_8.json");
var beast9 = require("../Beasts/Beast_9.json");
var beast10 = require("../Beasts/Beast_10.json");
var beast11 = require("../Beasts/Beast_11.json");
var beast12 = require("../Beasts/Beast_12.json");
var beast13 = require("../Beasts/Beast_13.json");


var Gem = artifacts.require("../contracts/Gem.sol");
var Beasts = artifacts.require("../contracts/Beasts.sol");
var MMR = artifacts.require("../contract/MMR.sol");
var Fight = artifacts.require("../contracts/Fight.sol");
var Menagerie = artifacts.require("../contracts/Menagerie.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("Fight and Menagerie", function (accounts) {
  before(async () => {
    gemInstance = await Gem.deployed();
    BeastsInstance = await Beasts.deployed();
    MMRinstance = await MMR.deployed();
    fightInstance = await Fight.deployed();
    menagerieInstance = await Menagerie.deployed();
  });

  console.log("Testing Fight and Menagerie contract");

  it("Get Gems", async () => {
    await gemInstance.getGems({
      from: accounts[1],
      value: oneEth,
    });

    await gemInstance.getGems({
      from: accounts[2],
      value: oneEth,
    })

    const amt1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1]})); // need to remember the await
    const amt2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2]})); // need to remember the await
    const correctAmt1 = new BigNumber(1000);

    await assert(amt1.isEqualTo(correctAmt1), "Incorrect amount of gems issued for account 1");
    await assert(amt2.isEqualTo(correctAmt1), "Incorrect amount of gems issued for account 2");
  });

  it("Approve Beasts Contract", async () => {
    // Give approval to Beast contract
    await gemInstance.giveGemApproval(BeastsInstance.address, 1000, { from: accounts[1]}); 
    await gemInstance.giveGemApproval(BeastsInstance.address, 1000, { from: accounts[2]}); 

    const allowance1 = new BigNumber(await gemInstance.checkGemAllowance(accounts[1], BeastsInstance.address));
    const allowance2 = new BigNumber(await gemInstance.checkGemAllowance(accounts[2], BeastsInstance.address));
    const correctAllowance = new BigNumber(1000);

    await assert(allowance1.isEqualTo(correctAllowance), "Allowance not given to contract correctly for account 1");
    await assert(allowance2.isEqualTo(correctAllowance), "Allowance not given to contract correctly for account 2");
  });

  it("Mint Beast", async () => {
    // Mint card (Beast 0) to account 1
    await BeastsInstance.mint(accounts[1], beast0.name, beast0.attributes[0].value, beast0.attributes[1].value, beast0.attributes[2].value, beast0.attributes[3].value, beast0.attributes[4].value);

    const name = await BeastsInstance.nameOf(0);
    const rarity = await BeastsInstance.rarityOf(0);
    const nature = await BeastsInstance.natureOf(0);
    const cost = await BeastsInstance.costOf(0);
    const attack = await BeastsInstance.attackOf(0);
    const health = await BeastsInstance.healthOf(0);
    const balance = new BigNumber(await gemInstance.checkGems({ from: accounts[1] }));
    const correctBalance = new BigNumber(995);

    await assert.equal(name, beast0.name, "Incorrect name");
    await assert.equal(rarity, beast0.attributes[0].value, "Incorrect rarity");
    await assert.equal(nature, beast0.attributes[1].value, "Incorrect nature");
    await assert.equal(cost, beast0.attributes[2].value, "Incorrect cost");
    await assert.equal(attack, beast0.attributes[3].value, "Incorrect attack");
    await assert.equal(health, beast0.attributes[4].value, "Incorrect health");
    await assert(balance.isEqualTo(correctBalance), "Incorrect gem balance");
  });

  it("Enter queue", async () => {
    // Mints 4 more cards for first player
    await BeastsInstance.mint(accounts[1], beast1.name, beast1.attributes[0].value, beast1.attributes[1].value, beast1.attributes[2].value, beast1.attributes[3].value, beast1.attributes[4].value);
    await BeastsInstance.mint(accounts[1], beast2.name, beast2.attributes[0].value, beast2.attributes[1].value, beast2.attributes[2].value, beast2.attributes[3].value, beast2.attributes[4].value);
    await BeastsInstance.mint(accounts[1], beast3.name, beast3.attributes[0].value, beast3.attributes[1].value, beast3.attributes[2].value, beast3.attributes[3].value, beast3.attributes[4].value);
    await BeastsInstance.mint(accounts[1], beast4.name, beast4.attributes[0].value, beast4.attributes[1].value, beast4.attributes[2].value, beast4.attributes[3].value, beast4.attributes[4].value);

    // Give allowance to Fight contract
    await gemInstance.giveGemApproval(fightInstance.address, 1000, { from: accounts[1]}); 

    // First player enters the queue if the queue is empty
    let joinQueue = await fightInstance.fight([0,1,2,3,4], { from: accounts[1]});

    truffleAssert.eventEmitted(joinQueue, "inQueue");
  });

  it("Fight between 2 players", async () => {
    // Mint 5 cards for player 2
    await BeastsInstance.mint(accounts[2], beast5.name, beast5.attributes[0].value, beast5.attributes[1].value, beast5.attributes[2].value, beast5.attributes[3].value, beast5.attributes[4].value);
    await BeastsInstance.mint(accounts[2], beast6.name, beast6.attributes[0].value, beast6.attributes[1].value, beast6.attributes[2].value, beast6.attributes[3].value, beast6.attributes[4].value);
    await BeastsInstance.mint(accounts[2], beast7.name, beast7.attributes[0].value, beast7.attributes[1].value, beast7.attributes[2].value, beast7.attributes[3].value, beast7.attributes[4].value);
    await BeastsInstance.mint(accounts[2], beast8.name, beast8.attributes[0].value, beast8.attributes[1].value, beast8.attributes[2].value, beast8.attributes[3].value, beast8.attributes[4].value);
    await BeastsInstance.mint(accounts[2], beast9.name, beast9.attributes[0].value, beast9.attributes[1].value, beast9.attributes[2].value, beast9.attributes[3].value, beast9.attributes[4].value);

    // Give allowance to Fight contract
    await gemInstance.giveGemApproval(fightInstance.address, 1000, { from: accounts[2] }); 

    let fight = await fightInstance.fight([5,6,7,8,9], { from: accounts[2] });

    let balance1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1]}));
    let balance2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2]}));
    let balance3 = new BigNumber(await gemInstance.checkGemsOf(fightInstance.address));
    let correctBalance1 = new BigNumber(1046);
    let correctBalance2 = new BigNumber(897);
    let correctBalance3 = new BigNumber(7);

    await assert(balance1.isEqualTo(correctBalance1), "Incorrect Gem Balance for account 1");
    await assert(balance2.isEqualTo(correctBalance2), "Incorrect Gem Balance for account 2");
    await assert(balance3.isEqualTo(correctBalance3), "Incorrect Gem Balance for Fight contract");

    truffleAssert.eventEmitted(fight, "outcomeWin", { winner: accounts[1] }, "Incorrect outcome");
  });

  it("Buy Beast on marketplace at listed price", async () => {
    // Mint new card
    await BeastsInstance.mint(accounts[1], beast10.name, beast10.attributes[0].value, beast10.attributes[1].value, beast10.attributes[2].value, beast10.attributes[3].value, beast10.attributes[4].value);

    let originalBalance1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1] }));
    let originalBalance2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2] }));
    let originalCommsBalance = new BigNumber(await menagerieInstance.checkCommission());
  
    // Set approval for beast card for marketplace to transfer 
    await BeastsInstance.approve(menagerieInstance.address, 10, { from: accounts[1] });

    // Set approval for marketplace to spend gems
    await gemInstance.giveGemApproval(menagerieInstance.address, 10000, { from: accounts[1]}); 
    await gemInstance.giveGemApproval(menagerieInstance.address, 10000, { from: accounts[2]}); 

    // List card
    await menagerieInstance.list(10, 20, { from: accounts[1] });

    // Buy card using account 2
    await menagerieInstance.buy(10, { from: accounts[2] });

    let newOwner = await BeastsInstance.ownerOf(10);
    assert.equal(newOwner, accounts[2], "Unsuccessful purchase of cards");

    let newBalance1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1] }));
    let newBalance2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2] }));
    let commsBalance = new BigNumber(await menagerieInstance.checkCommission());
    let price = new BigNumber(20);
    let comms = price * 5 / 100;

    assert((originalBalance1.plus(price)).isEqualTo(newBalance1), "Incorrect transfer of gems for account 1");
    assert((originalBalance2.minus(price.plus(comms))).isEqualTo(newBalance2), "Incorrect transfer of gems for account 2");
    assert((originalCommsBalance.plus(comms)).isEqualTo(commsBalance), "Incorrect transfer of gems for commissions");
  });

  it("Buy Beast on marketplace via offer", async () => {
    // Mint new card
    await BeastsInstance.mint(accounts[1], beast11.name, beast11.attributes[0].value, beast11.attributes[1].value, beast11.attributes[2].value, beast11.attributes[3].value, beast11.attributes[4].value);
    
    let originalBalance1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1] }));
    let originalBalance2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2] }));
    let originalCommsBalance = new BigNumber(await menagerieInstance.checkCommission());

    // Set approval for beast card for marketplace to transfer 
    await BeastsInstance.approve(menagerieInstance.address, 11, { from: accounts[1] });

    // List card
    await menagerieInstance.list(11, 40, { from: accounts[1] });

    // Make offer
    await menagerieInstance.makeOffer(11, 20, { from: accounts[2] });

    // Accept offer
    await menagerieInstance.acceptOffer(11, accounts[2], { from: accounts[1] });

    let newOwner = await BeastsInstance.ownerOf(11);
    assert.equal(newOwner, accounts[2], "Unsuccessful purchase of cards");

    let newBalance1 = new BigNumber(await gemInstance.checkGems({ from: accounts[1] }));
    let newBalance2 = new BigNumber(await gemInstance.checkGems({ from: accounts[2] }));
    let commsBalance = new BigNumber(await menagerieInstance.checkCommission());
    let price = new BigNumber(20);
    let comms = price * 5 / 100;

    assert((originalBalance1.plus(price)).isEqualTo(newBalance1), "Incorrect transfer of gems for account 1");
    assert((originalBalance2.minus(price.plus(comms))).isEqualTo(newBalance2), "Incorrect transfer of gems for account 2");
    assert((originalCommsBalance.plus(comms)).isEqualTo(commsBalance), "Incorrect transfer of gems for commissions");
  });

  it("Check offers", async () => {
    // Mint new card
    await BeastsInstance.mint(accounts[1], beast12.name, beast12.attributes[0].value, beast12.attributes[1].value, beast12.attributes[2].value, beast12.attributes[3].value, beast12.attributes[4].value);
    
    // List card
    await menagerieInstance.list(12, 40, { from: accounts[1] });

    // Get gems for account 3
    await gemInstance.getGems({
      from: accounts[3],
      value: oneEth,
    })

    // Make Offers
    await menagerieInstance.makeOffer(12, 20, { from: accounts[2] });
    await menagerieInstance.makeOffer(12, 25, { from: accounts[3] });

    let output = await menagerieInstance.checkOffers(12, {from: accounts[1]})

    await assert.equal(output[0]['owner'], accounts[2], "Incorrect owner of offer 1");
    await assert.equal(output[1]['owner'], accounts[3], "Incorrect owner of offer 2");
    await assert.equal(output[0]['offerValue'], 20, "Incorrect owner of offer 1");
    await assert.equal(output[1]['offerValue'], 25, "Incorrect owner of offer 2");
    await assert.equal(output[0]['offerCardId'], 12, "Incorrect card of offer 1");
    await assert.equal(output[1]['offerCardId'], 12, "Incorrect card of offer 2");
  });

  
  it("Check Withdrawal", async () => {
    // Mint new card
    await BeastsInstance.mint(accounts[1], beast13.name, beast13.attributes[0].value, beast13.attributes[1].value, beast13.attributes[2].value, beast13.attributes[3].value, beast13.attributes[4].value);
    
    // List card
    await menagerieInstance.list(13, 100, { from: accounts[1] });

    // Set approval for beast card for marketplace to transfer 
    await BeastsInstance.approve(menagerieInstance.address, 13, { from: accounts[1] });

    // Set approval for marketplace to spend gems
    await gemInstance.giveGemApproval(menagerieInstance.address, 10000, { from: accounts[1]}); 
    await gemInstance.giveGemApproval(menagerieInstance.address, 10000, { from: accounts[2]}); 

    await menagerieInstance.buy(13, { from: accounts[2] });

    await menagerieInstance.withdraw( {from: accounts[0]});

    let withdrawalBalance = new BigNumber(await gemInstance.checkGems({from: accounts[0]}))
    let balance = new BigNumber(7);
    await assert(withdrawalBalance.isEqualTo(balance), "Incorrect owner withdrawal amount");
  });
});
