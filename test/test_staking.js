const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.jstruff
var assert = require("assert");

var Gem = artifacts.require("../contracts/Gem.sol");
var LPtoken = artifacts.require("../contracts/LPtoken.sol");
var StakingRewards = artifacts.require("../contracts/StakingRewards.sol");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

contract("staking", function(accounts) {
    before(async () => {
        gemInstance = await Gem.deployed();
        LPinstance = await LPtoken.deployed();
        Stakingcontract = await StakingRewards.deployed();

        // Approve stakingRewards contract to spend staking and rewards tokens
        await LPinstance.getLPtoken({from: accounts[1], value: 1000000000000000000,});
        await LPinstance.giveLPtokenApproval(Stakingcontract.address, "10000000000000000000000", { from: accounts[1] });
        await LPinstance.giveLPtokenApproval(Stakingcontract.address, "10000000000000000000000", { from: accounts[2] });
        await gemInstance.getGems({from: accounts[0], value: 1000000000000000000,});
        await gemInstance.giveGemApproval(Stakingcontract.address, "1000000000000000000", {from: accounts[0]});
        await Stakingcontract.setStakingPoolLive({from: accounts[0]});
        // await gemInstance.transferGems(Stakingcontract.address, "10000", { from: accounts[1] });
    })

    const advanceTime = async (time) => {
        return new Promise((resolve, reject) => {
          web3.currentProvider.send(
            {
              jsonrpc: "2.0",
              method: "evm_increaseTime",
              params: [time],
              id: new Date().getTime(),
            },
            (err, result) => {
              if (err) {
                return reject(err);
              }
              return resolve(result);
            }
          );
        });
      };
      
    const advanceTimeAndMine = async (time) => {
        await advanceTime(time);
      
        return new Promise((resolve, reject) => {
          web3.currentProvider.send(
            {
              jsonrpc: "2.0",
              method: "evm_mine",
              id: new Date().getTime(),
            },
            (err, result) => {
              if (err) {
                return reject(err);
              }
              return resolve(result);
            }
          );
        });
      };
      
      

    //   it("should advance time correctly", async () => {
    //     const currentTime = (await web3.eth.getBlock("latest")).timestamp;
    //     console.log("Current Time:", currentTime);
      
    //     // Advance time by 100 seconds
    //     await advanceTimeAndMine(100);
      
    //     const newTime = (await web3.eth.getBlock("latest")).timestamp;
    //     console.log("New Time:", newTime);
      
    //     assert.equal(newTime, currentTime + 100, "Time was not advanced correctly");
    //   });
      
    
    it("should update rewards for staker1 after depositing", async () => {
        await Stakingcontract.stake("1000000000000000000", { from: accounts[1] });
        let block2 = await web3.eth.getBlock("latest");
        let currentTime = block2.timestamp;

        // Advance time by seconds
        await advanceTimeAndMine(86400)

        let block = await web3.eth.getBlock("latest");
        let lastUpdateTime = await Stakingcontract.lastRewardTimestamp();
        let timeElapsed = 86400;
        let rewardRate = await Stakingcontract.rewardPerSecond();
        let rewardAmount = timeElapsed * rewardRate;
        console.log("currentTime:", currentTime);
        console.log("lastUpdateTime:", lastUpdateTime.toString());
        console.log("timeElapsed:", timeElapsed);
        console.log("rewardRate:", rewardRate.toString());
        console.log("rewardAmount:", rewardAmount.toString());
    
        const pendingRewards1 = await Stakingcontract.pendingReward(accounts[1]);
        console.log("pendingRewards1:", pendingRewards1.toString());
    });

    it("should claim rewards for staker1", async () => {
        const initialBalance = await gemInstance.balanceOf(accounts[1]);
        await Stakingcontract.claimReward({ from: accounts[1] });

        const finalBalance = await gemInstance.balanceOf(accounts[1]);
        const rewardAmount = finalBalance.sub(initialBalance);
        console.log(initialBalance.toString());
        console.log(finalBalance.toString());
        console.log(rewardAmount.toString());
        // assert(rewardAmount.gt("0"), "Staker1 did not claim any rewards");
    });

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