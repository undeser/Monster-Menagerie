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


var Gem = artifacts.require("../contracts/Gem.sol");
var BeastCard = artifacts.require("../contracts/BeastCard.sol");
var MMR = artifacts.require("../contract/MMR.sol");
var Fight = artifacts.require("../contracts/Fight.sol");
// var Marketplace = artifacts.require("../contracts/Marketplace.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("Game", function (accounts) {
  before(async () => {
    gemInstance = await Gem.deployed();
    beastCardInstance = await BeastCard.deployed();
    MMRinstance = await MMR.deployed();
    fightInstance = await Fight.deployed();
  });

  console.log("Testing Game contract");

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

  it("Approve BeastCard Contract", async () => {
    // Give approval to Beast Card contract
    await gemInstance.giveGemApproval(beastCardInstance.address, 1000, { from: accounts[1]}); 
    await gemInstance.giveGemApproval(beastCardInstance.address, 1000, { from: accounts[2]}); 

    const allowance1 = new BigNumber(await gemInstance.checkGemAllowance(accounts[1], beastCardInstance.address));
    const allowance2 = new BigNumber(await gemInstance.checkGemAllowance(accounts[2], beastCardInstance.address));
    const correctAllowance = new BigNumber(1000);

    await assert(allowance1.isEqualTo(correctAllowance), "Allowance not given to contract correctly for account 1");
    await assert(allowance2.isEqualTo(correctAllowance), "Allowance not given to contract correctly for account 2");
  });

  it("Mint Beast Card", async () => {
    // Mint card (Beast 0) to account 1
    await beastCardInstance.mint(accounts[1], beast0.name, beast0.attributes[0].value, beast0.attributes[1].value, beast0.attributes[2].value, beast0.attributes[3].value, beast0.attributes[4].value);

    const name = await beastCardInstance.nameOf(0);
    const rarity = await beastCardInstance.rarityOf(0);
    const nature = await beastCardInstance.natureOf(0);
    const cost = await beastCardInstance.costOf(0);
    const attack = await beastCardInstance.attackOf(0);
    const health = await beastCardInstance.healthOf(0);
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
    await beastCardInstance.mint(accounts[1], beast1.name, beast1.attributes[0].value, beast1.attributes[1].value, beast1.attributes[2].value, beast1.attributes[3].value, beast1.attributes[4].value);
    await beastCardInstance.mint(accounts[1], beast2.name, beast2.attributes[0].value, beast2.attributes[1].value, beast2.attributes[2].value, beast2.attributes[3].value, beast2.attributes[4].value);
    await beastCardInstance.mint(accounts[1], beast3.name, beast3.attributes[0].value, beast3.attributes[1].value, beast3.attributes[2].value, beast3.attributes[3].value, beast3.attributes[4].value);
    await beastCardInstance.mint(accounts[1], beast4.name, beast4.attributes[0].value, beast4.attributes[1].value, beast4.attributes[2].value, beast4.attributes[3].value, beast4.attributes[4].value);

    // Give allowance to Fight contract
    await gemInstance.giveGemApproval(fightInstance.address, 1000, { from: accounts[1]}); 


    // First player enters the queue if the queue is empty
    let joinQueue = await fightInstance.fight([0,1,2,3,4], { from: accounts[1]});

    truffleAssert.eventEmitted(joinQueue, "inQueue");
  });

  it("Fight between 2 players", async () => {
    // Mint 5 cards for player 2
    await beastCardInstance.mint(accounts[2], beast5.name, beast5.attributes[0].value, beast5.attributes[1].value, beast5.attributes[2].value, beast5.attributes[3].value, beast5.attributes[4].value);
    await beastCardInstance.mint(accounts[2], beast6.name, beast6.attributes[0].value, beast6.attributes[1].value, beast6.attributes[2].value, beast6.attributes[3].value, beast6.attributes[4].value);
    await beastCardInstance.mint(accounts[2], beast7.name, beast7.attributes[0].value, beast7.attributes[1].value, beast7.attributes[2].value, beast7.attributes[3].value, beast7.attributes[4].value);
    await beastCardInstance.mint(accounts[2], beast8.name, beast8.attributes[0].value, beast8.attributes[1].value, beast8.attributes[2].value, beast8.attributes[3].value, beast8.attributes[4].value);
    await beastCardInstance.mint(accounts[2], beast9.name, beast9.attributes[0].value, beast9.attributes[1].value, beast9.attributes[2].value, beast9.attributes[3].value, beast9.attributes[4].value);

    // const numCards1 = new BigNumber(await beastCardInstance.balanceOf(accounts[1]));
    // const numCards2 = new BigNumber(await beastCardInstance.balanceOf(accounts[2]));
    // const correctNum = new BigNumber(5);

    // assert(numCards1.isEqualTo(correctNum), "Incorrect number of cards minted for account 1");
    // assert(numCards2.isEqualTo(correctNum), "Incorrect number of cards minted for account 2");

    // Give allowance to Fight contract
    await gemInstance.giveGemApproval(fightInstance.address, 1000, { from: accounts[2] }); 

    let fight = await fightInstance.fight([5,6,7,8,9], { from: accounts[2] });
    console.log(fight);

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
});
