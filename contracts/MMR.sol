// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MMR {
    mapping(address => uint256) internal _playerMMR;

    function isNew(address user) public view returns (bool) {
        return _playerMMR[user] == 0;
    }

    function initialiseUser(address user) public {
        if(_playerMMR[user] == 0) {
            _playerMMR[user] = 100;
        }
    }

    // Lowest MMR is 1
    // MMR = 0 means user has not been initialised
    function getMMR(address user) public view returns (uint256) {
        return _playerMMR[user];
    }

    // Function to update MMR given a loser and winner
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