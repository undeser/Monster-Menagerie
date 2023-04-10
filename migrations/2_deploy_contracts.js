const Gem = artifacts.require("Gem");
const Beasts = artifacts.require("Beasts");
const MMR = artifacts.require("MMR");
const Fight = artifacts.require("Fight");
const StakingRewards = artifacts.require("StakingRewards");
const LPtoken = artifacts.require("LPtoken");
const Menagerie = artifacts.require("Menagerie");

module.exports = (deployer, network, accounts) => {
    deployer
      .deploy(Gem) // deploy gem contract
      .then(function () {
        return deployer.deploy(Beasts, Gem.address, "Beast", "BST"); // deploy beasts contract
      })
      .then(function () {
        return deployer.deploy(MMR); // deploy MMR contract
      })
      .then(function () {
        return deployer.deploy(Fight, Gem.address, Beasts.address, MMR.address); // deploy fight contract
      })
      .then(function () {
        return deployer.deploy(Menagerie, Beasts.address, Gem.address); // deploy menagerie
      })
      .then (function () {
        return deployer.deploy(LPtoken)
      })
      .then(function () {
        return deployer.deploy(StakingRewards, LPtoken.address, Gem.address, 1000) 
        // 1000 Gem for the rewardPool distribution
      });
    }
