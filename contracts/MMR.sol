// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title MMR - Matchmaking Rating
 * @dev MMR stores the users' MMR.
 */
contract MMR {
    address owner;

    constructor() {
        owner = msg.sender;    
    }

    mapping(address => uint256) internal _playerMMR;

    /**
     * @dev Check if user is new to the game
     * @param user Address of user
     */
    function isNew(address user) public view returns (bool) {
        return _playerMMR[user] == 0;
    }

    /**
     * @dev Initialise new user
     * @param user Address of user
     */
    function initialiseUser(address user) public {
        if(_playerMMR[user] == 0) {
            _playerMMR[user] = 100;
        }
    }

    /**
     * @dev Getter for user MMR
     * @param user Address of user
     */
    function getMMR(address user) public view returns (uint256) {
        // Lowest MMR is 1
        // MMR = 0 means user has not been initialised
        return _playerMMR[user];
    }

    /**
     * @dev Update MMR for winner and loser
     * @param winner Address of winner
     * @param loser Address of loser
     */
    function updateMMR(address winner, address loser) public {
        uint256 winnerMMR = _playerMMR[winner];
        uint256 loserMMR = _playerMMR[loser];
        uint256 diff = winnerMMR - loserMMR;
        uint256 change = 10;
        if (diff > 0) {
            // Winner has higher MMR
            // Winner should win less and loser should lose less
            change = 5; 
        } else if (diff < 0) {
            // Loser has higher MMR
            // Loser should win more and winner should lose more
            change = 15;
        } 
        if (change >= loserMMR) {
            _playerMMR[winner] += change;
            _playerMMR[loser] = 1; // Set to 1 if lose till negative
        } else {
            _playerMMR[winner] += change;
            _playerMMR[loser] -= change;
        }
    }
}