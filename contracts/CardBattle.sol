// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./BeastCard.sol";

contract CardBattle {
    BeastCard cardContract;
    address[] matchmakingQueue; 

    constructor(BeastCard cardAddress) {
        cardContract = cardAddress;
    }

    mapping(address => uint256[]) internal _cardsOfPlayersInQueue;
    mapping(address => uint256) internal _playerMMR;

    event inQueue(address player);
    event outcomeWin(address winner);
    event outcomeDraw();

    function fight(uint256[] memory cards) public isOwnerOfCards(cards) isCorrectNumCards(cards) cardsNotBroken(cards) {
        // Matchmaking
        if (matchmakingQueue.length == 0) {
            // when nobody is in the queue to battle, join the queue
            matchmakingQueue.push(msg.sender);
            _cardsOfPlayersInQueue[msg.sender] = cards;

            emit inQueue(msg.sender);
        } else {
            // Battle
            // Loop through both the arrays of the cards and fight with each other in that order
            address enemy = matchmakingQueue[0];
            matchmakingQueue.pop();
            // uint256 enemyMMR = _playerMMR[enemy];
            uint256 myDmg = 0;
            uint256 enemyDmg = 0;
            uint256[] memory enemyCards = _cardsOfPlayersInQueue[enemy];
            for (uint i = 0; i < cards.length; i++) {
                if (cardContract.attackOf(cards[i]) > cardContract.healthOf(enemyCards[i])) {
                    // enemy card dies
                    cardContract.cardDestroyed(enemyCards[i]);

                    // extra dmg 
                    myDmg += (cardContract.attackOf(cards[i]) - cardContract.healthOf(enemyCards[i]));
                } 
                
                if (cardContract.attackOf(enemyCards[i]) > cardContract.healthOf(cards[i])) {
                    // my card dies 
                    cardContract.cardDestroyed(cards[i]);

                    // extra dmg
                    enemyDmg += (cardContract.attackOf(enemyCards[i]) - cardContract.healthOf(cards[i]));
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