pragma solidity ^0.8.0;

import './ERC20.sol';
import './SafeMath.sol';

contract LPstaking {
    ERC20 public lpToken;
    Gem public gem;
    uint256 public rewardPool = 100000 * 10**18; // 100,000 tokens with 18 decimals
    uint256 public totalRewardDistributed;

    struct StakeInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    mapping(address => StakeInfo) public stakes;
    uint256 public totalStaked;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ClaimReward(address indexed user, uint256 reward);

    constructor(address _lpToken, address _rewardToken) {
        lpToken = ERC20(_lpToken);
        rewardToken = Gem(_rewardToken);
    }

    function deposit(uint256 amount) public {
        updateReward(msg.sender);
        stakes[msg.sender].amount += amount;
        totalStaked += amount;
        lpToken.TransferFrom(msg.sender, address(this), amount);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(stakes[msg.sender].amount >= amount, "Withdraw: insufficient balance");
        updateReward(msg.sender);
        stakes[msg.sender].amount -= amount;
        totalStaked -= amount;
        lpToken.Transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount);
    }

    function claimReward() public {
        updateReward(msg.sender);
        uint256 reward = stakes[msg.sender].rewardDebt;
        stakes[msg.sender].rewardDebt = 0;
        require(totalRewardDistributed + reward <= rewardPool, "Not enough rewards left in the pool");
        totalRewardDistributed += reward;
        rewardToken.Transfer(msg.sender, reward);
        emit ClaimReward(msg.sender, reward);
    }

    function updateReward(address user) internal {
        uint256 reward = (stakes[user].amount * currentAPR()) / 1e18;
        stakes[user].rewardDebt += reward;
    }
    // reward distribution for a year
    function currentAPR() public view returns (uint256) {
        uint256 remainingRewardPool = rewardPool - totalRewardDistributed;
        return (remainingRewardPool * 1e18) / totalStaked;
    }

}