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
    });

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
        const currentTime = new BigNumber((await web3.eth.getBlock("latest")).timestamp);

        // Advance time by 100 seconds
        await advanceTimeAndMine(100);
      
        const newTime = new BigNumber((await web3.eth.getBlock("latest")).timestamp);
        const additionalTime = new BigNumber(100);

        assert(currentTime.plus(additionalTime).isEqualTo(newTime), "Time was not advanced correctly");
      });
      
    
    it("should update rewards for staker1 after depositing", async () => {
        const staking = await Stakingcontract.stake("1000000000000000000", { from: accounts[1] });

        // Advance time by seconds
        await advanceTimeAndMine(86400) // fast forward by 1 day (86400 seconds)

        const pendingRewards1 = new BigNumber(await Stakingcontract.pendingReward(accounts[1]));
        const oneDayReward = new BigNumber(2739726027397209600);
        // 2739726027397209600 is the calculation for 1 day reward with a 1000 Gem for reward distribution
        // 1000 / 365 = 2.73972602739726 * 1e18

        assert(pendingRewards1.isEqualTo(oneDayReward), "PendingReward is not updating properly for accounts[1]")
        truffleAssert.eventEmitted(staking, 'Stake')
    });

    it("should claim rewards for accounts[1]", async () => {
        const initialBalance = new BigNumber(await gemInstance.balanceOf(accounts[1]));
        const claiming = await Stakingcontract.claimReward({ from: accounts[1] });

        const finalBalance = new BigNumber(await gemInstance.balanceOf(accounts[1]));
        const oneDayReward = new BigNumber(2739726027397209600);

        assert(finalBalance.minus(initialBalance).isEqualTo(oneDayReward),"accounts[1] did not claim the correct rewards");
        truffleAssert.eventEmitted(claiming, 'ClaimReward');
    });

    it("The reward should split evenly after account[2] deposits", async () => {
        await Stakingcontract.stake("1000000000000000000", { from: accounts[2] });

        // Advance time by seconds
        await advanceTimeAndMine(86400) // fast forward by 1 day (86400 seconds)

        // 2739726027397209600 Gem rewards will be split between the 2 accounts
        const pendingRewards2 = new BigNumber(await Stakingcontract.pendingReward(accounts[2]));
        // Account 1 still have his balance staked from previously
        const pendingRewards1 = new BigNumber(await Stakingcontract.pendingReward(accounts[1])); 
        const rewardSplit = new BigNumber(1369863013698604800);
        // console.log(pendingRewards2.toString())
        // console.log(pendingRewards1.toString())
        // console.log(rewardSplit.toString())
        console.log(pendingRewards1);
        console.log(pendingRewards2)
        console.log(rewardSplit)
        console.log(pendingRewards1.isEqualTo(rewardSplit))
        assert(pendingRewards2.isEqualTo(rewardSplit),"reward did not update accordingly")
        assert(pendingRewards1.isEqualTo(rewardSplit),"reward did not update accordingly")
    });

    it("withdrawing", async () => {
        const initialBalance = new BigNumber(await gemInstance.balanceOf(accounts[2]));
        const withdrawing = await Stakingcontract.withdraw("500000000000000000", { from: accounts[2] });
        const finalBalance = new BigNumber(await gemInstance.balanceOf(accounts[2]));
        // const withdrawRewardsAmount = finalBalance.sub(initialBalance);
        // const printString = withdrawRewardsAmount.toString();
        const halfReward = new BigNumber(1369863013698604800);

        assert(finalBalance.minus(initialBalance).isEqualTo(halfReward), "Withdrawal of reward is not the correct amount");
        truffleAssert.eventEmitted(withdrawing, 'Withdraw');
        // add checking for event emitted
        // assert.equal(printString,"1369863013698604800", "Withdrawal of reward is not the correct amount");
        // assert(withdrawRewardsAmount.isEqualTo(1369863013698604800),"Withdrawal of reward is not the correct amount")
    });
    
    //account[1] holds 1 x 1e18, account[2] holds 0.5 x 1e18
    it("Reward should be split proportionally after account[3] depositing", async() => {
        // Claim any remaining rewards from account1
        await Stakingcontract.claimReward({ from: accounts[1] }); 

        const twoEth = new BigNumber(2000000000000000000); // 2 eth
        await LPinstance.getLPtoken({from: accounts[3], value: twoEth,});
        await LPinstance.giveLPtokenApproval(Stakingcontract.address, "2000000000000000001", { from: accounts[3] });
        await Stakingcontract.stake("2000000000000000000", { from: accounts[3] });
        
        await advanceTimeAndMine(172800) // fast forward by 1 day (86400 seconds)
        const oneDayReward = new BigNumber(2739726027397209600);
        const rewardSplitPerShare = oneDayReward.div(7);
        const account1Share = oneDayReward.div(7).times(4);
        const account2Share = new BigNumber(rewardSplitPerShare.times(2));
        const account3Share = new BigNumber(rewardSplitPerShare.times(8));

        const pendingRewards1 = new BigNumber(await Stakingcontract.pendingReward(accounts[1]));
        const pendingRewards2 = new BigNumber(await Stakingcontract.pendingReward(accounts[2]));
        const pendingRewards3 = new BigNumber(await Stakingcontract.pendingReward(accounts[3]));
        console.log(account1Share.toString())
        console.log(pendingRewards1.toString())
        assert(account1Share.isEqualTo(pendingRewards1), "Reward not reflecting the proportion correctly");
        assert(account2Share.isEqualTo(pendingRewards2), "Reward not reflecting the proportion correctly");
        assert(account3Share.isEqualTo(pendingRewards3), "Reward not reflecting the proportion correctly");
    })
});