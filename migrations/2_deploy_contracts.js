const Gem = artifacts.require("Gem");
const Monsters = artifacts.require("Monsters");
const MMR = artifacts.require("MMR");
const Fight = artifacts.require("Fight");
const StakingRewards = artifacts.require("StakingRewards");
const LPtoken = artifacts.require("LPtoken");
const Menagerie = artifacts.require("Menagerie");

module.exports = (deployer, network, accounts) => {
    deployer
      .deploy(Gem) // deploy gem contract
      .then(function () {
        return deployer.deploy(Monsters, Gem.address, "Monster", "M"); // deploy beast card contract
      })
      .then(function () {
        return deployer.deploy(MMR); // deploy MMR contract
      })
      .then(function () {
        return deployer.deploy(Fight, Gem.address, Monsters.address, MMR.address); // deploy fight contract
      })
      .then(function () {
        return deployer.deploy(Menagerie, Monsters.address, Gem.address); // deploy menagerie
      })
      .then (function () {
        return deployer.deploy(LPtoken)
      })
      .then(function () {
        return deployer.deploy(StakingRewards, LPtoken.address, Gem.address, 1000) 
        // 1000 Gem for the rewardPool distribution
      });
    }
