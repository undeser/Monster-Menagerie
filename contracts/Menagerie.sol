// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Gem.sol";
import "./Monsters.sol";

contract Menagerie {
    Monsters CardContract;
    Gem GemContract;
    address _owner = msg.sender;

    struct Offer {
        address owner;
        uint256 offerValue;
        uint256 offerCardId;
    }

    mapping(uint256 => uint256) listPrice;
    mapping(uint256 => Offer[]) offers;

    constructor(Monsters cardAddress, Gem gemAddress) {
        CardContract = cardAddress;
        GemContract = gemAddress;
    }

    /**
     * @dev List Monster for sale on marketplace
     * @param id ID of Monster
     * @param price Listed price of Monster
     */
    function list(uint256 id, uint256 price) public {
        require(msg.sender == CardContract.ownerOf(id), "Sorry you cannot list Monster as you are not the owner");
        listPrice[id] = price;
    }

    /**
     * @dev Unlist Monster from marketplace
     * @param id ID of Monster
     */
    function unlist(uint256 id) public {
        require(msg.sender == CardContract.ownerOf(id), "Sorry you cannot unlist Monster as you are not the owner");
        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Getter for listed price of Monster on marketplace
     * @param id ID of Monster
     */
    function checkPrice(uint256 id) public view returns(uint) {
        return uint(listPrice[id])*105/100; // Charge 5% commission
    }

    /**
     * @dev Make an offer to listing to purchase Monster
     * @param id ID of Monster
     * @param offerPrice Price of offer for Monster
     */
    function makeOffer(uint256 id, uint256 offerPrice) public {
        require(listPrice[id] != 0, "Monster is not listed for sale");
        require(GemContract.balanceOf(msg.sender) >= offerPrice, "Insufficient Gems");
        require(checkOfferExists(id, address(msg.sender)) == false, "You have already made an offer for this Monster");
        Offer memory newOffer = Offer({
            owner: address(msg.sender),
            offerValue: offerPrice,
            offerCardId: id
        });
        offers[id].push(newOffer);
    }

    /**
     * @dev View the offers for the Monster
     * @param id ID of Monster
     */
    function checkOffers(uint256 id) public view returns(Offer[] memory) {
        require(msg.sender == CardContract.ownerOf(id), "Sorry you cannot view the offers for this Monster as you are not the owner");
        uint256 numOffers = offers[id].length;
        Offer[] memory offerIds = new Offer[](numOffers);
        for (uint i = 0; i < numOffers; i++) {
            Offer storage offer = offers[id][i];
            offerIds[i] = offer;
        }
        return offerIds;
    }

    /**
     * @dev Accept offer made by offerer for Monster
     * @param id ID of Monster
     * @param offerer Address of offerer for the Monster
     */
    function acceptOffer(uint256 id, address offerer) public {
        require(msg.sender == CardContract.ownerOf(id), "Sorry you cannot accept offers for this Monster as you are not the owner");
        require(checkOfferExists(id, offerer) == true, "Offer does not exist");
        uint256 price;

        uint256 numOffers = offers[id].length;
        for (uint i = 0; i < numOffers; i++) {
            if(offers[id][i].owner == offerer) {
                price = offers[id][i].offerValue;
            }
        }

        GemContract.transferGemsFrom(offerer, msg.sender, price);
        GemContract.transferGemsFrom(offerer, address(this), price* 5/100);
        CardContract.safeTransferFrom(msg.sender, offerer, id);

        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Check if an offer exists
     * @param id ID of Monster
     * @param offerer Address of offerer
     */
    function checkOfferExists(uint256 id, address offerer) public view returns(bool exists) {
        uint256 numOffers = offers[id].length;
        for (uint i = 0; i < numOffers; i++) {
            if(offers[id][i].owner == offerer) {
                exists = true;
                return exists;
            }
        }
    }

    /**
     * @dev Retract offer that was already made for a Monster
     * @param id ID of Monster
     */
    function retractOffer(uint256 id) public {
        require(checkOfferExists(id, address(msg.sender)) == true, "You have not made an offer for this Monster");
        address Offerer = address(msg.sender);
        uint256 numOffers = offers[id].length;
        for (uint i = 0; i < numOffers; i++) {
            if(offers[id][i].owner == Offerer) {
                offers[id][i] = offers[id][numOffers - 1];
                offers[id].pop();
            }
        }
    }

    /**
     * @dev Buy Monster at listed price
     * @param id ID of Monster
     */
    function buy(uint256 id) public {
        require(listPrice[id] != 0, "Monster is not listed for sale");
        require(GemContract.balanceOf(msg.sender) >= this.checkPrice(id), "Insufficient Gems");

        address recipent = address(uint160(CardContract.ownerOf(id)));
        address seller = recipent;
        GemContract.transferGemsFrom(msg.sender ,recipent, listPrice[id]); // transfer price to seller
        GemContract.transferGemsFrom(msg.sender, address(this), listPrice[id]*5/100); // transfer commission to this contract
        CardContract.safeTransferFrom(seller, address(msg.sender), id);

        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Getter for address of owner of contract
     */
    function getContractOwner() public view returns(address) {
        return _owner;
    }

    /**
     * @dev Withdraw commission from marketplace to contract owner
     */
    function withDraw() public { 
        require(msg.sender == _owner, "Sorry, you are not allowed to do that");
        if(msg.sender == _owner) {
            GemContract.transferGems(msg.sender, address(this).balance);
        }
    }
    
    /**
     * @dev Check commission made from marketplace
     */
    function checkCommission() public view returns(uint256) {
        require(msg.sender == _owner, "Sorry, you are not allowed to do that");
        return GemContract.checkGemsOf(address(this));
    }
}