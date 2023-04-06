pragma solidity ^0.8.0;

import './ERC20.sol';
import './SafeMath.sol';
import './Gem.sol';

contract LPstaking2 {
    ERC20 public lpToken;
    Gem public gem;
    uint256 public totalRewardPool;
    uint256 public totalStaked;
    uint256 public lastUpdateBlock;
    uint256 public accRewardPerShare;

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
        lastUpdateBlock = block.number;
        totalRewardPool = _rewardPool * 1e18;
    }

    function deposit(uint256 amount) public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        if (user.stakedAmount > 0) {
            uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;
            if (pendingReward > 0) {
                uint256 payout = (pendingReward > totalRewardPool) ? totalRewardPool : pendingReward;
                gem.transfer(msg.sender, payout);
                totalRewardPool -= payout;
            }
        }
        lpToken.transferFrom(msg.sender, address(this), amount);
        user.stakedAmount += amount;
        totalStaked += amount;
        user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
    }

    function withdraw(uint256 amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.stakedAmount >= amount, "Not enough staked tokens");

        updatePool();

        uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;
        if (pendingReward > 0) {
            uint256 payout = (pendingReward > totalRewardPool) ? totalRewardPool : pendingReward;
            gem.transfer(msg.sender, payout);
            totalRewardPool -= payout;
        }

        lpToken.transfer(msg.sender, amount);
        user.stakedAmount -= amount;
        totalStaked -= amount;
        user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
    }

    function updatePool() public {
        if (block.number <= lastUpdateBlock) {
            return;
        }
        if (totalStaked == 0) {
            lastUpdateBlock = block.number;
            return;
        }

        uint256 blocksSinceLastUpdate = block.number - lastUpdateBlock;
        uint256 reward = (totalRewardPool * blocksSinceLastUpdate) / (block.number - lastUpdateBlock);
        accRewardPerShare += (reward * 1e18) / totalStaked;
        lastUpdateBlock = block.number;
    }

    function getPendingReward(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 _accRewardPerShare = accRewardPerShare;
        if (block.number > lastUpdateBlock && totalStaked != 0) {
            uint256 blocksSinceLastUpdate = block.number - lastUpdateBlock;
            uint256 reward = (totalRewardPool * blocksSinceLastUpdate) / (block.number - lastUpdateBlock);
            _accRewardPerShare += (reward * 1e18) / totalStaked;
        }
        return user.stakedAmount * _accRewardPerShare / 1e18 - user.rewardDebt;
    }

    function claimRewards() public {
        UserInfo storage user = userInfo[msg.sender];
        updatePool();

        uint256 pendingReward = user.stakedAmount * accRewardPerShare / 1e18 - user.rewardDebt;

        if (pendingReward > 0) {
            gem.transfer(msg.sender, pendingReward);

            user.rewardDebt = user.stakedAmount * accRewardPerShare / 1e18;
            emit RewardClaimed(msg.sender, pendingReward);
        }
    }

}