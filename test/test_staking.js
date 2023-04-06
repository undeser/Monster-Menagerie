const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.jstruff
var assert = require("assert");

var Gem = artifacts.require("../contracts/Gem.sol");
var LPtoken = artifacts.require("../contracts/Gem.sol");
var StakingRewards = artifacts.require("../contracts/StakingRewards.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("staking", function(accounts) {
    before(async () => {
        gemInstance = await Gem.deployed();
        LPinstance = await LPtoken.deployed();
        Stakingcontract = await StakingRewards.deployed();

        // Approve stakingRewards contract to spend staking and rewards tokens
        await LPinstance.getGems({from: accounts[1], value: 1000000000000000000,});
        await LPinstance.approve(Stakingcontract.address, "10000000000000000000000", { from: accounts[1] });
        await LPinstance.approve(Stakingcontract.address, "10000000000000000000000", { from: accounts[2] });
        await gemInstance.getGems({from: accounts[0], value: 1000000000000000000,});
        await gemInstance.giveGemApproval(Stakingcontract.address, "1000000000000000000", {from: accounts[0]});
        await Stakingcontract.setStakingPoolLive({from: accounts[0]});
        // await gemInstance.transferGems(Stakingcontract.address, "10000", { from: accounts[1] });
    })
    console.log("testing");

    it("should update rewards for staker1 after depositing", async () => {
        
        await Stakingcontract.stake("1000000000000000000", { from: accounts[1] });

        // Fast forward time by 1 day
        await new Promise((resolve) => setTimeout(resolve, 1000));
        // await Stakingcontract._updateRewards(accounts[1], { from: accounts[1] });

        const pendingRewards1 = await Stakingcontract.getPendingReward(accounts[1]);
        console.log(pendingRewards1.toString());
        assert.isAbove(pendingRewards1,0, "Staker1 rewards did not update");
    });

    // it("should claim rewards for staker1", async () => {
    //     const initialBalance = await rewardsToken.balanceOf(staker1);
    //     await stakingRewards.claimReward({ from: staker1 });

    //     const finalBalance = await rewardsToken.balanceOf(staker1);
    //     const rewardAmount = finalBalance.sub(initialBalance);

    //     assert(rewardAmount.gt("0"), "Staker1 did not claim any rewards");
    // });

    // it("should update rewards for staker2 after depositing and waiting for 2 days", async () => {
    //     await stakingRewards.deposit("2000000000000000000", { from: staker2 });

    //     // Fast forward time by 2 days
    //     await new Promise((resolve) => setTimeout(resolve, 2000));
    //     await stakingRewards.updateRewards(staker2, { from: staker2 });

    //     const pendingRewards2 = await stakingRewards.getPendingReward(staker2);
    //     assert(pendingRewards2.gt("0"), "Staker2 rewards did not update");
    // });

    // it("should claim rewards for staker2", async () => {
    //     const initialBalance = await rewardsToken.balanceOf(staker2);
    //     await stakingRewards.claimReward({ from: staker2 });

    //     const finalBalance = await rewardsToken.balanceOf(staker2);
    //     const rewardAmount = finalBalance.sub(initialBalance);

    //     assert(rewardAmount.gt("0"), "Staker2 did not claim any rewards");
    // });
});