// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC20.sol';
import './Gem.sol';
import'./LPtoken.sol';

import "@openzeppelin/contracts/utils/math/SafeMath.sol"; // npm install @openzeppelin/contracts

contract StakingRewards {
    using SafeMath for uint256;
    LPtoken public lpToken;
    Gem public gem;

    uint256 public rewardPerSecond;
    uint256 public totalStakingShares;
    uint256 public accGemPerShare;
    uint256 public lastRewardTimestamp;
    uint256 public maxDailyReward;
    uint256 public totalRewardPool;

    address public owner;
    bool public stakingPoolLive;
    
    event Stake(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 amount);
    event StakingPoolLive(bool poolStatus);

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => StakeInfo) public stakers;

    constructor(address stakingToken, address rewardsToken, uint256 rewardPool) {
        lpToken = LPtoken(stakingToken);
        gem = Gem(rewardsToken);
        totalRewardPool = rewardPool;
        maxDailyReward = (totalRewardPool * 1e18) / 365;
        rewardPerSecond = maxDailyReward / 86400; // Fixed reward distribution by the second but the proportion of the reward 
                                                // will be determined by the staker share in the pool (accGemPerShare)
        lastRewardTimestamp = block.timestamp;
        stakingPoolLive = false; // this variable will turn to true once the contract deployer sends the gem (_rewardPool) 
                                //into the contract
        owner = msg.sender;
    }

    function setStakingPoolLive() public onlyOwner {
        require(gem.checkGemsOf(msg.sender) >= totalRewardPool, "You do not have sufficient Gem for the rewardPool");
        require(stakingPoolLive == false, "Staking pool is already live");
        gem.transferGemsFrom(msg.sender, address(this), totalRewardPool);
        stakingPoolLive = true;
        emit StakingPoolLive(true);
    }

    function updatePool() internal {
        if (block.timestamp <= lastRewardTimestamp) {
            return;
        }

        if (totalStakingShares == 0) {
            lastRewardTimestamp = block.timestamp;
            return;
        }

        uint256 multiplier = block.timestamp.sub(lastRewardTimestamp);
        uint256 gemReward = multiplier.mul(rewardPerSecond);
        accGemPerShare = accGemPerShare.add(gemReward.mul(1e18).div(totalStakingShares));
        lastRewardTimestamp = block.timestamp;
    }

    function pendingReward(address _user) external view checkStakingPoolStatus returns (uint256) {
        StakeInfo storage user = stakers[_user];
        uint256 _accGemPerShare = accGemPerShare;
        if (block.timestamp > lastRewardTimestamp && totalStakingShares != 0) {
            uint256 multiplier = block.timestamp.sub(lastRewardTimestamp);
            uint256 gemReward = multiplier.mul(rewardPerSecond);
            _accGemPerShare = _accGemPerShare.add(gemReward.mul(1e18).div(totalStakingShares));
        }
        return user.amount.mul(_accGemPerShare).div(1e18).sub(user.rewardDebt);
    }

    function stake(uint256 amountToStake) external checkStakingPoolStatus {
        require(amountToStake > 0, "Cannot stake 0 tokens");
        updatePool();
        StakeInfo storage user = stakers[msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                gem.transfer(msg.sender, pending);
            }
        }
        if (amountToStake > 0) {
            lpToken.transferLPtokenFrom(msg.sender, address(this), amountToStake);
            user.amount = user.amount.add(amountToStake);
            totalStakingShares = totalStakingShares.add(amountToStake);
        }
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
        emit Stake(msg.sender, amountToStake);
    }

    function withdraw(uint256 amountToWithdraw) external checkStakingPoolStatus {
        StakeInfo storage user = stakers[msg.sender];
        require(user.amount >= amountToWithdraw, "withdraw: not enough balance");
        updatePool();
        uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            gem.transfer(msg.sender, pending);
        }
        if (amountToWithdraw > 0) {
            user.amount = user.amount.sub(amountToWithdraw);
            totalStakingShares = totalStakingShares.sub(amountToWithdraw);
            lpToken.transfer(msg.sender, amountToWithdraw);
        }
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
        emit Withdraw(msg.sender, amountToWithdraw);
    }

    function claimReward() external checkStakingPoolStatus {
        updatePool();
        StakeInfo storage user = stakers[msg.sender];
        uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
        require(pending > 0, "claimReward: no rewards to claim");
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
        gem.transfer(msg.sender, pending);
        emit ClaimReward(msg.sender, pending);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'Ownable: caller is not the owner');
        _;
    }

    modifier checkStakingPoolStatus() {
        require(stakingPoolLive, 'Staking Pool is not live yet, Please get the Owner to deposit the rewards');
        _;
    }
}

