pragma solidity ^0.8.0;

import './IERC20.sol';
import './SafeMath.sol';

contract LPstaking {
    using SafeMath for uint256;
    address public lpToken;
    mapping(address => uint256) public balances;
    mapping (address => uint256) public userRewardPerTokenPaid;
    mapping (address => uint256) public rewards;
    uint256 public totalStaked;
    uint256 public rewardRate;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public periodFinish;

    constructor (address lpTokenAddress, uint256 stakingRewardRate) {
        lpToken = lpTokenAddress;
        rewardRate = stakingRewardRate;
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp.add(30 days); 
    }

    function stake(uint256 amount) public {
        require(amount > 0, 'Cannot stake 0 LP tokens');
        updateReward(msg.sender);
        IERC20(lpToken).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        totalStaked = totalStaked.add(amount);
    }

    function unstake(uint256 amount) public {
        require(amount > 0, 'Cannot unstake 0 LP tokens');
        updateReward(msg.sender);
        IERC20(lpToken).transfer(msg.sender, amount);
        balances[msg.sender] = balances[msg.sender].sub(amount);
        totalStaked = totalStaked.sub(amount);
    }

    function updateReward(address account) internal {
        rewardPerTokenStored = rewardPerToken(); // The staking yield
        lastUpdateTime = lastTimeRewardApplicable(); 
        if (account != address(0)) {
            balances[account] = earned(account);
        }
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored.add(
            lastTimeRewardApplicable()
                .sub(lastUpdateTime)
                .mul(rewardRate)
                .mul(1e18)
                .div(totalStaked)
        );
    }

    function earned(address account) public view returns (uint256) {
        return balances[account]
            .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
            .div(1e18)
            .add(rewards[account]);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }
}