pragma solidity ^0.5.0;

import "./Gem.sol";

contract Stake {
    Gem GemContract;

     // 30 Days (30 * 24 * 60 * 60)
    uint256 public planDuration = 2592000;

    // 180 Days (180 * 24 * 60 * 60)
    uint256 _planExpired = 15552000;

    uint8 public interestRate = 32;
    uint256 public planExpired;
    uint8 public totalStakers;
    struct StakeInfo {        
        uint256 start;
        uint256 end;        
        uint256 amount; 
        uint256 claimed;       
    }
    
    event Staked(address indexed from, uint256 amount);
    event Claimed(address indexed from, uint256 amount);
    
    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    function stakeToken(uint256 stakeAmount) external payable whenNotPaused {
        GemContract.transferFrom(msg.sender, address(this), stakeAmount); // gotta check this logic
        totalStakers++;
        addressStaked[msg.sender] = true;

        stakeInfos[msg.sender] = StakeInfo({
            start: block.timestamp,
            end: block.timestamp + planDuration,
            amount: stakeAmount,
            claimed: 0
        });

        emit staked(msg.sender, stakeAmount);
    }

    function getTokenExpiry() external view returns (uint256) {
        return stakeInfos[msg.sender].end;
    }

    function claimReward() external returns (bool) {
        uint256 stakeAmount = stakeInfos[msg.sender].amount;
        uint256 totalTokens = stakeAmount + (stakeAmount + interestRate/100);
        stakeInfos[msg.sender].claimed = totalTokens;
        GemContract.transfer(msg.sender(), totalTokens);

        emit Claimed(msg.sender(), totalTokens);
        return true;
    }
}