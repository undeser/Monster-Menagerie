pragma solidity ^0.8.0;

import './ERC20.sol';
import './Gem.sol';

contract StakingRewards {
    ERC20 public lpToken;
    Gem public gem;

    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public maxDailyReward;
    uint256 public rewardRate;
    uint256 public totalStaked;
    uint256 public dailyRewardCounter;
    uint256 public totalRewardPool;
    address public contractOwner;
    bool public stakingPoolLive;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardPerTokenPaid;
        uint256 rewards;
    }

    mapping(address => StakeInfo) public stakers;

    event Staked(address indexed user, uint256 amount, uint256 currentTime, uint256 lastUpdateTime, uint256 timeElapsed, uint256 rewardRate, uint256 rewardAmount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardUpdated(uint256 currentTime, uint256 timeElapsed, uint256 rewardAmount, uint256 rewardToDistribute);
    event RewardToDistribute(uint256 rewardToDistribute);

    constructor(address _stakingToken, address _rewardsToken, uint256 _rewardPool) {
        lpToken = ERC20(_stakingToken);
        gem = Gem(_rewardsToken);
        totalRewardPool = _rewardPool;
        maxDailyReward = (totalRewardPool * 1e18) / 365;
        rewardRate = maxDailyReward / 86400; // Assuming rewards are distributed evenly over 24 hours
        lastUpdateTime = block.timestamp;
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

    // function _updateRewards(address account) public {
    //     _resetDailyRewardCounterIfNeeded();
    //     uint256 currentTime = block.timestamp;
    //     uint256 timeElapsed = currentTime - lastUpdateTime;
    //     if (totalStaked > 0) {
    //         uint256 rewardAmount = (timeElapsed * rewardRate) / 1e18;
    //         uint256 rewardToDistribute = (dailyRewardCounter + rewardAmount <= maxDailyReward) ? rewardAmount : maxDailyReward - dailyRewardCounter;

    //         rewardPerTokenStored = rewardPerTokenStored + (rewardToDistribute/ totalStaked);
    //         dailyRewardCounter += rewardToDistribute;
    //         emit RewardUpdated(currentTime, timeElapsed, rewardAmount, rewardToDistribute);
    //     }
    //     lastUpdateTime = currentTime;
    //     if (account != address(0)) {
    //         stakers[account].rewards = earned(account);
    //         stakers[account].rewardPerTokenPaid = rewardPerTokenStored;
    //     }
    // }
    function _updateRewards(address account) public{
        _resetDailyRewardCounterIfNeeded();
        uint256 currentTime = block.timestamp;

        uint256 timeElapsed = currentTime - lastUpdateTime;
        if (totalStaked > 0) {
            uint256 rewardAmount = (timeElapsed * rewardRate);
            uint256 rewardToDistribute = (dailyRewardCounter + rewardAmount <= maxDailyReward) ? rewardAmount : maxDailyReward - dailyRewardCounter;

            rewardPerTokenStored = rewardPerTokenStored + (rewardToDistribute / totalStaked);
            dailyRewardCounter += rewardToDistribute;
        }

        lastUpdateTime = currentTime;
        
        if (account != address(0)) {
            stakers[account].rewards = earned(account);
            stakers[account].rewardPerTokenPaid = rewardPerTokenStored;
        }
    }



    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((((block.timestamp - lastUpdateTime) * rewardRate)/ 1e18) / totalStaked);
    }

    function earned(address account) public view returns (uint256) {
        return (stakers[account].amount * (rewardPerToken() - stakers[account].rewardPerTokenPaid)) + stakers[account].rewards;
    }

    // function stake(uint256 amount) external {
    //     require(amount > 0, "Cannot stake 0 tokens");
    //     _updateRewards(msg.sender);
    //     lpToken.transferFrom(msg.sender, address(this), amount);
    //     totalStaked = totalStaked + amount;
    //     stakers[msg.sender].amount = stakers[msg.sender].amount + amount;
    //     emit Staked(msg.sender, amount);
    // }

    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0 tokens");
        _updateRewards(msg.sender);
        lpToken.transferFrom(msg.sender, address(this), amount);
        totalStaked = totalStaked + amount;
        stakers[msg.sender].amount += amount;        
    }


    function withdraw(uint256 amount) external {
        require(stakers[msg.sender].amount >= amount, "Insufficient staked balance");
        // withdraw can only be called by the depositor
        _updateRewards(msg.sender);
        stakers[msg.sender].amount = stakers[msg.sender].amount - amount;
        totalStaked = totalStaked - amount;
        lpToken.transfer(msg.sender, amount);
        //this.claimReward();
        emit Withdrawn(msg.sender, amount);
    }

    function claimReward() external {
        _updateRewards(msg.sender);
        uint256 reward = stakers[msg.sender].rewards;

        if (reward > 0) {
            stakers[msg.sender].rewards = 0;
            gem.transferGems(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    // function getPendingReward(address account) public returns (uint256) {
    //     _updateRewards(msg.sender);
    //     return earned(account);
    // }

    function getPendingReward(address account) public view returns (uint256) {
        StakeInfo memory user = stakers[account];
        uint256 _rewardPerToken = rewardPerToken();
        return (user.amount * (_rewardPerToken - user.rewardPerTokenPaid)) + user.rewards;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner, 'Ownable: caller is not the owner');
        _;
    }

    modifier checkStakingPoolStatus() {
        require(stakingPoolLive, 'Staking Pool is not live yet, Please get the Owner to deposit the rewards');
        _;
    }
}
