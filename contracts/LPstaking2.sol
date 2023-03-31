pragma solidity ^0.8.0;

import './IERC20.sol';
import './SafeMath.sol';

contract LPstaking2 {
    using SafeMath for uint256;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 arxRewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of ARXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accArxPerShare) - user.arxRewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accArxPerShare` (and `lastRewardTime`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `arxRewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 gemAllocPoint; // Accumulated Gem per share
        uint256 accGemPerShare; 
        uint256 lastRewardTime;  // Last block number that ARXs distribution occurs.
        uint256 totalDeposit;
    }

    // GEM Token
    Gem public gem;
    uint256 public gemPerSec;
    // The address of the treasury
    address public treasury;
    // The block number when Gem received its' last reward
    uint256 public lastTeamRewardBlockTime = type(uint256).max;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public gemTotalAllocPoint = 0;
    // The block number when ARX mining starts.
    uint256 public startTime = type(uint256).max;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        address _treasury, // dont think need this
        Gem gemTokenInstance,
        uint256 gemPerSec,
    ) public {
        treasury = _treasury;
        gem = gemTokenInstance;
        gemPerSec = gemPerSec;
    }

    // Allows users to see if rewards have started
    function rewardsStarted() public view returns(bool) {
        return (block.timestamp >= startTime);
    }

    function setTreasury(address _treasury) public onlyOwner {
        treasury = _treasury;
    }

    function updateGemPerSec(uint256 _gemPerSec) public onlyOwner {
        gemPerSec = _gemPerSec;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _gemAllocPoint, IBEP20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools(); // havent check this yet
        }
        uint256 lastRewardTime = block.timestamp > startTime ? block.timestamp : startTime;
        gemTotalAllocPoint = gemTotalAllocPoint.add(_gemAllocPoint);

        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            gemAllocPoint: _gemAllocPoint,
            lastRewardTime: lastRewardTime,
            accGemPerShare: 0,
            totalDeposit: 0
        }));
    }

    // Update the given pool's ARX allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _gemAllocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        gemTotalAllocPoint = gemTotalAllocPoint.sub(poolInfo[_pid].gemTotalAllocPoint).add(_gemAllocPoint);

        poolInfo[_pid].gemTotalAllocPoint = _gemAllocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    // View function to see pending ARXs on frontend.
    function pendingArx(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accGemPerShare = pool.accGemPerShare;
        uint256 lpSupply = pool.totalDeposit;
        if (block.timestamp > pool.lastRewardTime && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
            uint256 arxReward = multiplier.mul(arxPerSec).mul(pool.arxAllocPoint).div(arxTotalAllocPoint);
            accArxPerShare = accArxPerShare.add(arxReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accArxPerShare).div(1e12).sub(user.arxRewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        uint256 lpSupply = pool.totalDeposit;
        if (lpSupply == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardTime, block.timestamp);
        uint256 arxReward = multiplier.mul(arxPerSec).mul(pool.arxAllocPoint).div(arxTotalAllocPoint);
        arx.mintFor(address(this), arxReward);

        pool.accArxPerShare = pool.accArxPerShare.add(arxReward.mul(1e12).div(lpSupply));
        if (pool.WETHAllocPoint != 0 || WETHTotalAllocPoint != 0) {
            uint256 WETHReward = multiplier.mul(WETHPerSec).mul(pool.WETHAllocPoint).div(WETHTotalAllocPoint);
            pool.accWETHPerShare = pool.accWETHPerShare.add(WETHReward.mul(1e12).div(lpSupply));
        }
        pool.lastRewardTime = block.timestamp;

        if (block.timestamp >= (lastTeamRewardBlockTime + teamTimeInbetweenRewards)) { // If it has been a week since the last team's reward
            uint256 teamMultiplier = getMultiplier(lastTeamRewardBlockTime, block.timestamp);
            uint256 teamReward = teamMultiplier.mul(teamRewardPerSec);
            if (teamTotalReward + teamReward <= totalAllowedTeamReward) {
                // Update the last team's reward to the current block's timestamp
                lastTeamRewardBlockTime = block.timestamp;
                // Update the total amount that the team has receivevd
                teamTotalReward = teamTotalReward.add(teamReward);
                // Mint the team's reward and have it deposited in the multsig/treasury
                arx.mintFor(treasury, teamReward);
            }
        }
    }

    // transfer pending rewards
    function transferPendingRewards(uint256 _pid, address _account) internal{
        uint256 pendingArxReward = pendingArx(_pid, _account);
        if(pendingArxReward > 0) {
            safeArxTransfer(_account, pendingArxReward);
        }
        uint256 pendingWETHReward = pendingWETH(_pid, _account);
        if(pendingWETHReward > 0) {
            safeWETHTransfer(_account, pendingWETHReward);
        }
    }

    // Deposit LP tokens to MasterChef for ARX allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            transferPendingRewards(_pid, msg.sender);
        }
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            pool.totalDeposit = pool.totalDeposit.add(_amount);
        }
        user.arxRewardDebt = user.amount.mul(pool.accArxPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        transferPendingRewards(_pid, msg.sender);

        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
            pool.totalDeposit = pool.totalDeposit.sub(_amount);
        }
        user.arxRewardDebt = user.amount.mul(pool.accArxPerShare).div(1e12);
        user.WETHRewardDebt = user.amount.mul(pool.accWETHPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }


    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.arxRewardDebt = 0;
        user.WETHRewardDebt = 0;
    }

    function safeArxTransfer(address _to, uint256 _amount) internal {
        uint256 arxBal = arx.balanceOf(address(this));
        if (_amount > arxBal) {
            arx.transfer(_to, arxBal);
        } else {
            arx.transfer(_to, _amount);
        }
    }
    function safeWETHTransfer(address _to, uint256 _amount) internal {
        uint256 WETHBal = WETH.balanceOf(address(this));
        if (_amount > WETHBal) {
            WETH.transfer(_to, WETHBal);
        } else {
            WETH.transfer(_to, _amount);
        }
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        require(block.timestamp < startTime && block.timestamp < _startTime);
        startTime = _startTime;

        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            poolInfo[pid].lastRewardTime = startTime;
        }

        lastTeamRewardBlockTime = startTime;
    }
}




// contract LPstaking2 {
//     IERC20 public lpToken;
//     uint256 public tokenDistribution;
//     uint256 stakingYield;
//     uint256 totalStaked;
//     uint256 public lastUpdateTime;
//     uint256 public periodFinish;
//     struct stakeInfo {
//         uint256 amount;
//         uint256 rewardDebt;
//         // uint256 daysLeft; // Days left for staking contract?
//     }
//     mapping(address => stakeInfo) public currentStakers;


//     constructor(address lpTokenAddress, uint256 rewardAmount) {
//         lpToken = IERC20(lpTokenAddress);
//         tokenDistribution = rewardAmount;
//         lastUpdateTime = block.timestamp;
//     }

//     function deposit(uint256 depositAmount, uint256 lockUpDays) public {
//         require(depositAmount > 0, 'Please deposit a non-zero value');
//         updateStakeInfo(address(this));
//         updateStakingYield();
//         currentStakers[address(this)].amount += depositAmount;
//         totalStaked += depositAmount;
//     }
//     function updateStakeInfo(address depositor) private {
//         currentStakers[depositor].rewardDebt = 
//     }

//     //
//     function updateStakingYield() private return(uint256) {

//     }

//     function lastTimeRewardApplicable() public view returns (uint256) {
//         return block.timestamp < periodFinish ? block.timestamp : periodFinish;
//     }

//     function setRewardRate(uint256 newRewardRate) public onlyOwner {
//         rewardRate = newRewardRate;
//     }
// }