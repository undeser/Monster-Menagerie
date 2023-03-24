// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.2;

// contract MMR {
//     mapping(address => uint256) _playerMMR;

//     // lowest possible MMR for any given player is 1, cannot decrease less than 1
//     // by default when instantiated, everyone will be 0
//     function exists(address sender) public view returns (bool) {
//         return _playerMMR[sender] != 0;
//     }

//     function setNewPlayer(address sender) public {
//         // by default the starting MMR will be 100
//         _playerMMR[sender] = 100; 
//     }

//     function outcome(address winner, address loser) public {

//     }
// }