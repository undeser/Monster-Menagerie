// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BeastCard.sol";

contract Fight {
    BeastCard cardContract;
    // MMR mmrContract;
    address[] matchmakingQueue; 

    constructor(BeastCard cardAddress, MMR mmrAddress) {
        cardContract = cardAddress;
        // mmrContract = mmrAddress;
    }

    mapping(address => uint256[]) internal _cardsOfPlayersInQueue;
    mapping(address => uint256) internal _scale;
    // mapping(address => uint256) internal _playerMMR;

    event inQueue(address player);
    event outcomeWin(address winner);
    event outcomeDraw();

    function fight(uint256[] memory cards) public isOwnerOfCards(cards) isCorrectNumCards(cards) cardsNotBroken(cards) {
        // Get cost
        uint256 cost = 0;
        for (uint i = 0; i < cards.length; i++) {
            cost += cardContract.costOf(cards[i]);
        }
        require(cost <= 65, "Cost exceeded threshold");

        // Determine the scale of MY TEAM
        uint scale = 10;
        scale = (((65 / cost) / 20 ) + 1) * 10;

        // if (!mmrContract.exists(msg.sender)) {
        //     // Sets the MMR for the new player
        //     mmrContract.setNewPlayer(msg.sender); 
        // } else {

        // }


        // Matchmaking
        if (matchmakingQueue.length == 0) {
            // when nobody is in the queue to battle, join the queue
            matchmakingQueue.push(msg.sender);
            _cardsOfPlayersInQueue[msg.sender] = cards;
            _scale[msg.sender] = scale;

            emit inQueue(msg.sender);
        } else {
            // Battle
            // Loop through both the arrays of the cards and fight with each other in that order
            address enemy = matchmakingQueue[0];
            matchmakingQueue.pop();
            uint256 enemyScale = _scale[enemy];
            // uint256 enemyMMR = _playerMMR[enemy];
            uint256 myDmg = 0;
            uint256 enemyDmg = 0;
            uint256[] memory enemyCards = _cardsOfPlayersInQueue[enemy];
            for (uint i = 0; i < cards.length; i++) {
                if (cardContract.attackOf(cards[i]) * scale > cardContract.healthOf(enemyCards[i]) * enemyScale) {
                    // enemy card dies
                    cardContract.cardDestroyed(enemyCards[i]);

                    // extra dmg 
                    myDmg += (cardContract.attackOf(cards[i]) * scale - cardContract.healthOf(enemyCards[i]) * enemyScale);
                } 
                
                if (cardContract.attackOf(enemyCards[i]) * enemyScale > cardContract.healthOf(cards[i]) * scale) {
                    // my card dies 
                    cardContract.cardDestroyed(cards[i]);

                    // extra dmg
                    enemyDmg += (cardContract.attackOf(enemyCards[i]) * enemyScale - cardContract.healthOf(cards[i]) * scale);
                }
            }

            if (myDmg > enemyDmg) {
                // I win 
                // transfer token
                emit outcomeWin(msg.sender);
            } else if (myDmg < enemyDmg) {
                // Enemy win
                // transfer token
                emit outcomeWin(enemy);
            } else {
                // Draw
                emit outcomeDraw();
            }
        }
    }

    modifier isOwnerOfCards(uint256[] memory cards) {
        for (uint i = 0; i < cards.length; i++) {
            // Requires all the cards to be owned by the player
            require(cardContract.ownerOf(cards[i]) == msg.sender, "Card does not belong to player");
        }
        _;
    }

    modifier isCorrectNumCards(uint256[] memory cards) {
        require(cards.length == 5, "Too little cards");
        _;
    }

    modifier cardsNotBroken(uint256[] memory cards) {
        for (uint i = 0; i < cards.length; i++) {
            require(cardContract.stateOf(cards[i]) != BeastCard.cardState.broken, "Card is broken");
        }
        _;
    }
}
