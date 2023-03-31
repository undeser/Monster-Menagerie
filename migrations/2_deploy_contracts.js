const Gem = artifacts.require("Gem");
const BeastCard = artifacts.require("BeastCard");
const Fight = artifacts.require("Fight");
// const Marketplace = artifacts.require("Marketplace");

module.exports = (deployer, network, accounts) => {
    deployer
      .deploy(Gem)
      .then(function () {
        return deployer.deploy(BeastCard, Gem.address, "Beast", "BST");
      })
      .then(function () {
        return deployer.deploy(Fight, Gem.address, BeastCard.address);
      });
  };
