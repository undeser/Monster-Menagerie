pragma solidity ^0.8.0;

import './ERC20.sol';
import './SafeMath.sol';
import './Gem.sol';

contract LPstaking {
    ERC20 public lpToken;
    Gem public gem;
    // Pool details
    uint256 public totalRewardPool;
    uint256 public totalStaked;
    address public contractOwner;
    bool public stakingPoolLive;

    // Updating Pool contract for rewards
    uint256 public lastRewardUpdateTimestamp;
    uint256 public dailyRewardCounter;
    uint256 public maxDailyReward;
    uint256 public accRewardPerShare;

    uint256 public rewardRate;
    uint256 public rewardPerTokenStored;
    uint256 public lastUpdateTime;

    struct UserInfo {
        uint256 stakedAmount;
        uint256 rewardDebt;
    }

    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 reward);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _lpToken, address _rewardToken, uint256 _rewardPool) {
        lpToken = ERC20(_lpToken);
        gem = Gem(_rewardToken);
        lastRewardUpdateTimestamp = block.timestamp;
        totalRewardPool = _rewardPool;
        maxDailyReward = _rewardPool / 365;
        stakingPoolLive = false; // this variable will turn to true once the contract deployer sends the gem (_rewardPool) 
                                        //into the contract
        contractOwner = msg.sender;
    }

    function setStakingPoolLive() public onlyOwner {
            // uint256 rewardPool = totalRewardPool / 1e18;
            require(gem.checkGemsOf(msg.sender) >= totalRewardPool, "You do not have sufficient Gem for the rewardPool");
            gem.transferGemsFrom(msg.sender, address(this), totalRewardPool);
            stakingPoolLive = true;
    }

    function deposit(uint256 amount) public checkStakingPoolStatus {
        require(lpToken.balanceOf(msg.sender) >= amount, "You do not have sufficient Gem for the deposit");
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        if (user.stakedAmount > 0) {
            // uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;
            uint256 pendingReward = user.stakedAmount * accRewardPerShare - user.rewardDebt;
            if (pendingReward > 0) {
                uint256 payout = (pendingReward > totalRewardPool) ? totalRewardPool : pendingReward;
                gem.transferGems(msg.sender, payout);
                totalRewardPool -= payout;
            }
        }
        lpToken.transferFrom(msg.sender, address(this), amount);
        user.stakedAmount += amount;
        totalStaked += amount;
        // user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
        user.rewardDebt = user.stakedAmount * accRewardPerShare;
    }

    function withdraw(uint256 amount) public checkStakingPoolStatus {
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount >= amount, "Not enough staked tokens");

        updatePool();

        // uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;
        uint256 pendingReward = user.stakedAmount * accRewardPerShare - user.rewardDebt;

        if (pendingReward > 0) {
            uint256 payout = (pendingReward > totalRewardPool) ? totalRewardPool : pendingReward;
            gem.transferGems(msg.sender, payout);
            totalRewardPool -= payout;
        }

        lpToken.transfer(msg.sender, amount);
        user.stakedAmount -= amount;
        totalStaked -= amount;
        user.rewardDebt = user.stakedAmount * accRewardPerShare;
        // user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
    }

    function updatePool() public checkStakingPoolStatus {
        if (block.number <= lastRewardUpdateTimestamp) {
            return;
        }
        if (totalStaked == 0) {
            lastRewardUpdateTimestamp = block.number;
            return;
        }

        uint256 blocksSinceLastUpdate = block.number - lastRewardUpdateTimestamp;
        uint256 reward = (totalRewardPool * blocksSinceLastUpdate) / (block.number - lastRewardUpdateTimestamp);
        // accRewardPerShare += (reward * 1e18) / totalStaked;
        accRewardPerShare += (reward) / totalStaked;
        lastRewardUpdateTimestamp = block.number;
    }

    function getPendingReward(address _user) public view checkStakingPoolStatus returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastRewardUpdateTimestamp && totalStaked != 0) {
            uint256 blocksSinceLastUpdate = block.number - lastRewardUpdateTimestamp;
            uint256 reward = (totalRewardPool * blocksSinceLastUpdate) / (block.number - lastRewardUpdateTimestamp);
            // _accRewardPerShare += (reward * 1e18) / totalStaked;
            _accRewardPerShare += (reward) / totalStaked;
        }
        // return user.stakedAmount * _accRewardPerShare / 1e18 - user.rewardDebt;
        return user.stakedAmount * _accRewardPerShare - user.rewardDebt;
    }

    function claimRewards() public checkStakingPoolStatus {
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount > 0, "You do not have any LP token staked");
        updatePool();

        // uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;
        uint256 pendingReward = user.stakedAmount * accRewardPerShare - user.rewardDebt;

        if (pendingReward > 0) {
            gem.transferGems(msg.sender, pendingReward);

            // user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
            user.rewardDebt = user.stakedAmount * accRewardPerShare;
            emit RewardClaimed(msg.sender, pendingReward);
        }
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