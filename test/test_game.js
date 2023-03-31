const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var Gem = artifacts.require("../contracts/Gem.sol");
var BeastCard = artifacts.require("../contracts/BeastCard.sol");
var Fight = artifacts.require("../contracts/Fight.sol");
// var Marketplace = artifacts.require("../contracts/Marketplace.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("Game", function (accounts) {
  before(async () => {
    gemInstance = await Gem.deployed();
    beastCardInstance = await BeastCard.deployed();
    fightInstance = await Fight.deployed();
  });

  console.log("Testing Game contract");

  it("Get Gems", async () => {
    await gemInstance.getCredit({
      from: accounts[1],
      value: oneEth,
    });

    const amt1 = new BigNumber(gemInstance.balanceOf(accounts[1], { from: accounts[1]}));
    const correctAmt1 = new BigNumber(1000);

    console.log(amt1);

    await assert(amt1.isEqualTo(correctAmt1), "Incorrect gems amount issued");
  });
});
