// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Gem.sol";
import "./Beasts.sol";
import "./MMR.sol";

/**
 * @title Fight
 * @dev Fight is the main functionality of our game, where an array of 5 Beasts fight with another 5 Beasts and 
 * and the winner wins gems based on the difference in damage dealt to the opponent.
 */
contract Fight {
    Beasts cardContract;
    Gem gemContract;
    MMR mmrContract;
    address[] matchmakingQueue; 
    address owner;

    /**
     * Sets the values for the owner of contract, gemContract, cardContract and mmrContract
     * @param gemAddress Address of deployed Gem contract
     * @param cardAddress Address of deployed Beasts contract
     * @param mmrAddress Address of deployed MMR contract
     */
    constructor(Gem gemAddress, Beasts cardAddress, MMR mmrAddress) {
        owner = msg.sender;
        cardContract = cardAddress;
        gemContract = gemAddress;
        mmrContract = mmrAddress;
    }

    // owner => array of cards (for players in queue)
    mapping(address => uint256[]) internal _cardsOfPlayersInQueue;
    // owner => scale
    mapping(address => uint256) internal _scale;

    event inQueue(address player);
    event cardBroken(uint256 cardId);
    event damageDifference(uint256 diff);
    event outcomeWin(address winner);
    event outcomeDraw();

    /**
     * @dev Places a user to the matchmaking queue if queue is empty, else battle with the person at the top of the queue
     * @param cards Array of 5 IDs of Beasts in a specified order
     */
    function fight(uint256[] memory cards) public isOwnerOfCards(cards) isCorrectNumCards(cards) cardsNotBroken(cards) {
        // Get cost
        uint256 cost = 0;
        for (uint i = 0; i < cards.length; i++) {
            cost += cardContract.costOf(cards[i]);
        }
        require(cost <= 65, "Cost exceeded threshold");

        // Store in an array of scales due to solidity variable limits
        uint[] memory scales = new uint[](3);

        // Default scale
        scales[0] = 10;

        // Determine the scale of MY TEAM
        // Our algorithm to scale the team stats based on the total cost used
        // scales[1] = (((65 / cost) / 20 ) + 1) * 10;
        scales[1] = ((65 - cost) / 10) + 10;

        if (matchmakingQueue.length == 0) {
            // Matchmaking
            // When nobody is in the queue to battle, join the queue
            matchmakingQueue.push(msg.sender);
            _cardsOfPlayersInQueue[msg.sender] = cards;
            _scale[msg.sender] = scales[1];

            emit inQueue(msg.sender);
        } else {
            // Battle of cards
            // Loop through both the arrays of the cards and fight with each other in that order
            address enemy = matchmakingQueue[0];
            matchmakingQueue.pop();

            // Enemy's scale
            scales[2] = _scale[enemy];

            // uint256 enemyMMR = _playerMMR[enemy];
            uint256[] memory dmg = new uint256[](2);
            uint256[] memory enemyCards = _cardsOfPlayersInQueue[enemy];
            
            for (uint i = 0; i < cards.length; i++) {
                // Elemental scaling
                uint[] memory elementalScales = getElementalScales(cards[i], enemyCards[i]);

                if (cardContract.attackOf(cards[i]) * scales[1] * elementalScales[0] > cardContract.healthOf(enemyCards[i]) * scales[2] * elementalScales[1]) {
                    // Enemy card is broken
                    cardContract.cardDestroyed(enemyCards[i]);

                    emit cardBroken(enemyCards[i]);

                    // Extra dmg 
                    dmg[0] += (cardContract.attackOf(cards[i]) * scales[1] * elementalScales[0] - cardContract.healthOf(enemyCards[i]) * scales[2] * elementalScales[1]);
                } 
                
                if (cardContract.attackOf(enemyCards[i]) * scales[2] * elementalScales[1] > cardContract.healthOf(cards[i]) * scales[1] * elementalScales[0]) {
                    // My card is broken
                    cardContract.cardDestroyed(cards[i]);

                    emit cardBroken(cards[i]);

                    // Extra dmg 
                    dmg[1] += (cardContract.attackOf(enemyCards[i]) * scales[2] * elementalScales[1] - cardContract.healthOf(cards[i]) * scales[1] * elementalScales[0]);
                }
            }

            // Initialise if they are new users
            if (mmrContract.isNew(enemy)) {
                mmrContract.initialiseUser(enemy);
            }

            if (mmrContract.isNew(msg.sender)) {
                mmrContract.initialiseUser(msg.sender);
            }

            // Outcome determination
            // Fight contract takes a commission of 10% per fight 
            // Commission goes to the developing team + a "prize pool" that will be disbursed to top 10 players of the season
            // Divide by 100 to unscale the scaling effects from elemental scaling and cost scaling
            if (dmg[0] > dmg[1]) {
                // I win 
                mmrContract.updateMMR(msg.sender, enemy);

                // Gems transfer from loser to winner
                gemContract.transferGemsFrom(enemy, msg.sender, (dmg[0] - dmg[1]) * 9 / 100);

                // Gems transfer from loser to Fight contract
                gemContract.transferGemsFrom(enemy, address(this), (dmg[0] - dmg[1]) / 100);
                emit outcomeWin(msg.sender);
            } else if (dmg[0] < dmg[1]) {
                // Enemy wins
                mmrContract.updateMMR(enemy, msg.sender);

                // Gems transfer from loser to winner
                gemContract.transferGemsFrom(msg.sender, enemy, (dmg[1] - dmg[0]) * 9 / 100);

                // Gems transfer from loser to Fight contract
                gemContract.transferGemsFrom(msg.sender, address(this), (dmg[1] - dmg[0]) / 100);
                emit outcomeWin(enemy);
            } else {
                // Draw
                // No gems are being transferred anywhere
                emit outcomeDraw();
            }
        }
    }

    /**
     * @dev Getter for the elemental scales of 2 Beasts
     * @param myCard ID of my Monster
     * @param enemyCard ID of enemy Monster
     */
    function getElementalScales(uint256 myCard, uint256 enemyCard) internal view returns (uint[] memory) {
            uint[] memory elementalScales = new uint[](2);
            // Set default elementalScales for mine and enemy's 
            // 10 means 1x multiplier
            elementalScales[0] = 10; 
            elementalScales[1] = 10;

            if (cardContract.effective(myCard, enemyCard)) {
                elementalScales[0] += 1;
            } else if (cardContract.effective(enemyCard, myCard)) {
                elementalScales[1] += 1;
            }

            return elementalScales;
    }

    /**
     * @dev Withdraw gem commissions from fight back to owner of contract
     */
    function withdraw() public {
        uint256 amt = gemContract.checkGems();
        gemContract.transferGems(owner, amt);
    }

    /**
     * @dev Modifier to check if all cards belong to player
     */
    modifier isOwnerOfCards(uint256[] memory cards) {
        for (uint i = 0; i < cards.length; i++) {
            // Requires all the cards to be owned by the player
            require(cardContract.ownerOf(cards[i]) == msg.sender, "Beast does not belong to player");
        }
        _;
    }

    /**
     * @dev Modifier to check if number of cards are correct in the array of card ids
     */
    modifier isCorrectNumCards(uint256[] memory cards) {
        // Require the number of cards to be exactly 5
        require(cards.length == 5, "Too little cards");
        _;
    }

    /**
     * @dev Modifier to check if cards are all functional
     */
    modifier cardsNotBroken(uint256[] memory cards) {
        // Require the cards to be functional
        for (uint i = 0; i < cards.length; i++) {
            require(cardContract.stateOf(cards[i]) != Beasts.cardState.broken, "Beast is broken, please repair the Beast");
        }
        _;
    }
}
