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

        // Approve Stakingcontract contract to spend staking and rewards tokens
        await LPinstance.getLPtoken({from: accounts[1], value: oneEth,});
        await LPinstance.getLPtoken({from: accounts[2], value: oneEth,});
        await LPinstance.giveLPtokenApproval(Stakingcontract.address, "1000000000000000001", { from: accounts[1] });
        await LPinstance.giveLPtokenApproval(Stakingcontract.address, "1000000000000000001", { from: accounts[2] });
        await gemInstance.getGems({from: accounts[0], value: oneEth,});
        await gemInstance.giveGemApproval(Stakingcontract.address, oneEth, {from: accounts[0]});
        // initialise the staking pool to go live
        await Stakingcontract.setStakingPoolLive({from: accounts[0]});
    })

    // Creating the advance time function to simulate the staking of several days
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
      
      it("should advance time correctly", async () => {
        const currentTime = (await web3.eth.getBlock("latest")).timestamp;
      
        // Advance time by 100 seconds
        await advanceTimeAndMine(100);
      
        const newTime = (await web3.eth.getBlock("latest")).timestamp;
      
        assert.equal(newTime, currentTime + 100, "Time was not advanced correctly");
        // Sometimes the newTime and currentTime might be off by a few digit, just rerun the test
      });
      
    
    it("should update rewards for staker1 after depositing", async () => {
        await Stakingcontract.stake("1000000000000000000", { from: accounts[1] });

        // Advance time by seconds
        await advanceTimeAndMine(86400) // fast forward by 1 day (86400 seconds)

        const pendingRewards1 = await Stakingcontract.pendingReward(accounts[1]);
        const printString = pendingRewards1.toString();
        assert.equal(printString, "2739726027397209600", "PendingReward is not updating properly for accounts[1]");
        // 2739726027397209600 is the calculation for 1 day reward with a 1000 Gem for reward distribution
        // 1000 / 365 = 2.73972602739726 * 1e18
    });

    it("should claim rewards for accounts[1]", async () => {
        const initialBalance = await gemInstance.balanceOf(accounts[1]);
        await Stakingcontract.claimReward({ from: accounts[1] });

        const finalBalance = await gemInstance.balanceOf(accounts[1]);
        const rewardAmount = finalBalance.sub(initialBalance);
        const printString = rewardAmount.toString();

        assert.equal(printString, "2739726027397209600", "accounts[1] did not claim the correct rewards");
    });

    it("The reward should split evenly after account[2] deposits", async () => {
        await Stakingcontract.stake("1000000000000000000", { from: accounts[2] });

        // Advance time by seconds
        await advanceTimeAndMine(86400) // fast forward by 1 day (86400 seconds)

        // 2739726027397209600 Gem rewards will be split between the 2 accounts
        const pendingRewards2 = await Stakingcontract.pendingReward(accounts[2]);
        // Account 1 still have his balance staked from previously
        const pendingRewards1 = await Stakingcontract.pendingReward(accounts[1]); 
        const printString2 = pendingRewards2.toString();
        const printString1 = pendingRewards1.toString();

        assert.equal(printString2,"1369863013698604800", "reward did not update accordingly");
        assert.equal(printString1,"1369863013698604800", "reward did not update accordingly");
    });

    it("withdrawing", async () => {
        const initialBalance = await gemInstance.balanceOf(accounts[2])
        await Stakingcontract.withdraw("500000000000000000", { from: accounts[2] });
        const finalBalance = await gemInstance.balanceOf(accounts[2])
        const withdrawRewardsAmount = finalBalance.sub(initialBalance);
        const printString = withdrawRewardsAmount.toString();
        
        // add checking for event emitted
        assert.equal(printString,"1369863013698604800", "Withdrawal of reward is not the correct amount");
    });
    
    // it("should claim rewards for account[2]", async () => {
    //     const initialBalance = await rewardsToken.balanceOf(staker2);
    //     await stakingRewards.claimReward({ from: staker2 });

    //     const finalBalance = await rewardsToken.balanceOf(staker2);
    //     const rewardAmount = finalBalance.sub(initialBalance);

    //     assert(rewardAmount.gt("0"), "account[2] did not claim any rewards");
    // });
});