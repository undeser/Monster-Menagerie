const Gem = artifacts.require("Gem");
const BeastCard = artifacts.require("BeastCard");
const Fight = artifacts.require("Fight");
const StakingRewards = artifacts.require("StakingRewards");
const LPtoken = artifacts.require("LPtoken");
// const Marketplace = artifacts.require("Marketplace");

module.exports = (deployer, network, accounts) => {
    deployer
      .deploy(Gem)
      .then (function () {
        return deployer.deploy(LPtoken)
      })
      .then(function () {
        return deployer.deploy(StakingRewards, LPtoken.address, Gem.address, 1000)
      });
  };
