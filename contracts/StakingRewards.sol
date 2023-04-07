pragma solidity ^0.8.0;

import './ERC20.sol';
import './Gem.sol';
import'./LPtoken.sol';

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract StakingRewards {
    using SafeMath for uint256;
    LPtoken public lpToken;
    Gem public gem;

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public maxDailyReward;
    uint256 public rewardRate;
    uint256 public totalStaked;
    uint256 public totalRewardPool;

    address public contractOwner;
    bool public stakingPoolLive;
    
    uint256 public rewardPerSecond;
    uint256 public totalStakingShares;
    uint256 public accGemPerShare;
    uint256 public lastRewardTimestamp;
    uint256 public dailyRewardCounter;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => StakeInfo) public stakers;

    constructor(address _stakingToken, address _rewardsToken, uint256 _rewardPool) {
        lpToken = LPtoken(_stakingToken);
        gem = Gem(_rewardsToken);
        totalRewardPool = _rewardPool;
        maxDailyReward = (totalRewardPool * 1e18) / 365;
        rewardPerSecond = maxDailyReward / 86400; // Assuming rewards are distributed evenly over 24 hours
        lastRewardTimestamp = block.timestamp;
        stakingPoolLive = false; // this variable will turn to true once the contract deployer sends the gem (_rewardPool) 
                                //into the contract
        contractOwner = msg.sender;
    }

    function setStakingPoolLive() public onlyOwner {
        require(gem.checkGemsOf(msg.sender) >= totalRewardPool, "You do not have sufficient Gem for the rewardPool");
        require(stakingPoolLive == false, "Staking pool is already live");
        gem.transferGemsFrom(msg.sender, address(this), totalRewardPool);
        stakingPoolLive = true;
    }

    function _resetDailyRewardCounterIfNeeded() private {
        if (block.timestamp - lastUpdateTime >= 86400) {
            dailyRewardCounter = 0;
        }
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

    function pendingReward(address _user) external view returns (uint256) {
        StakeInfo storage user = stakers[_user];
        uint256 _accGemPerShare = accGemPerShare;
        if (block.timestamp > lastRewardTimestamp && totalStakingShares != 0) {
            uint256 multiplier = block.timestamp.sub(lastRewardTimestamp);
            uint256 gemReward = multiplier.mul(rewardPerSecond);
            _accGemPerShare = _accGemPerShare.add(gemReward.mul(1e18).div(totalStakingShares));
        }
        return user.amount.mul(_accGemPerShare).div(1e18).sub(user.rewardDebt);
    }

    function stake(uint256 _amount) external {
        updatePool();
        StakeInfo storage user = stakers[msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
            if (pending > 0) {
                gem.transfer(msg.sender, pending);
            }
        }
        if (_amount > 0) {
            lpToken.transferLPtokenFrom(msg.sender, address(this), _amount);
            user.amount = user.amount.add(_amount);
            totalStakingShares = totalStakingShares.add(_amount);
        }
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
    }

    function withdraw(uint256 _amount) external {
        StakeInfo storage user = stakers[msg.sender];
        require(user.amount >= _amount, "withdraw: not enough balance");
        updatePool();
        uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
        if (pending > 0) {
            gem.transfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            totalStakingShares = totalStakingShares.sub(_amount);
            lpToken.transfer(msg.sender, _amount);
        }
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
    }

    function claimReward() external {
        updatePool();
        StakeInfo storage user = stakers[msg.sender];
        uint256 pending = user.amount.mul(accGemPerShare).div(1e18).sub(user.rewardDebt);
        require(pending > 0, "claimReward: no rewards to claim");
        user.rewardDebt = user.amount.mul(accGemPerShare).div(1e18);
        gem.transfer(msg.sender, pending);
    }


    // function _updateRewards(address account) public{
    //     _resetDailyRewardCounterIfNeeded();
    //     uint256 currentTime = block.timestamp;

    //     uint256 timeElapsed = currentTime - lastUpdateTime;
    //     if (totalStaked > 0) {
    //         uint256 rewardAmount = (timeElapsed * rewardRate);
    //         uint256 rewardToDistribute = (dailyRewardCounter + rewardAmount <= maxDailyReward) ? rewardAmount : maxDailyReward - dailyRewardCounter;

    //         rewardPerTokenStored = rewardPerTokenStored + (rewardToDistribute / totalStaked);
    //         dailyRewardCounter += rewardToDistribute;
    //     }

    //     lastUpdateTime = currentTime;
        
    //     if (account != address(0)) {
    //         stakers[account].rewards = earned(account);
    //         stakers[account].rewardPerTokenPaid = rewardPerTokenStored;
    //     }
    // }
    
    // function rewardPerToken() public view returns (uint256) {
    //     if (totalStaked == 0) {
    //         return rewardPerTokenStored;
    //     }
    //     return rewardPerTokenStored + (((block.timestamp - lastUpdateTime) * rewardRate) / totalStaked);
    // }

    // function earned(address account) public view returns (uint256) {
    //     return (stakers[account].amount * (rewardPerToken() - stakers[account].rewardPerTokenPaid)) + stakers[account].rewards;
    // }

    // function stake(uint256 amount) external {
    //     require(amount > 0, "Cannot stake 0 tokens");
    //     _updateRewards(msg.sender);
    //     lpToken.transferFrom(msg.sender, address(this), amount);
    //     totalStaked = (totalStaked + amount);
    //     stakers[msg.sender].amount = stakers[msg.sender].amount + amount;
    // }


    // function withdraw(uint256 amount) external {
    //     require(stakers[msg.sender].amount >= amount, "Insufficient staked balance");
    //     // withdraw can only be called by the depositor
    //     _updateRewards(msg.sender);
    //     stakers[msg.sender].amount = stakers[msg.sender].amount - amount;
    //     totalStaked = totalStaked - amount;
    //     lpToken.transfer(msg.sender, amount);
    //     //this.claimReward();
    // }

    // function claimReward() external {
    //     _updateRewards(msg.sender);
    //     uint256 reward = stakers[msg.sender].rewards;

    //     if (reward > 0) {
    //         stakers[msg.sender].rewards = 0;
    //         gem.transferGems(msg.sender, reward);
    //     }
    // }

    // function getPendingReward(address account) public view returns (uint256) {
    //     StakeInfo memory user = stakers[account];
    //     uint256 _rewardPerToken = rewardPerToken();
    //     return (user.amount * (_rewardPerToken - user.rewardPerTokenPaid)) + user.rewards;
    // }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, 'Ownable: caller is not the owner');
        _;
    }

    modifier checkStakingPoolStatus() {
        require(stakingPoolLive, 'Staking Pool is not live yet, Please get the Owner to deposit the rewards');
        _;
    }
}

