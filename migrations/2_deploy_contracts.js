const Gem = artifacts.require("Gem");
const BeastCard = artifacts.require("BeastCard");
const MMR = artifacts.require("MMR");
const Fight = artifacts.require("Fight");
// const Marketplace = artifacts.require("Marketplace");

module.exports = (deployer, network, accounts) => {
    deployer
      .deploy(Gem) // deploy gem contract
      .then(function () {
        return deployer.deploy(BeastCard, Gem.address, "Beast", "BST"); // deploy beast card contract
      })
      .then(function () {
        return deployer.deploy(MMR); // deploy MMR contract
      })
      .then(function () {
        return deployer.deploy(Fight, Gem.address, BeastCard.address, MMR.address); // deploy fight contract
      });
  };
