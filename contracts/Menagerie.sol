// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Gem.sol";
import "./Beasts.sol";

contract Menagerie {
    Beasts cardContract;
    Gem gemContract;
    address owner = msg.sender;

    struct Offer {
        address owner;
        uint256 offerValue;
        uint256 offerCardId;
    }

    mapping(uint256 => uint256) listPrice;
    mapping(uint256 => Offer[]) offers;

    constructor(Beasts cardAddress, Gem gemAddress) {
        cardContract = cardAddress;
        gemContract = gemAddress;
    }

    /**
     * @dev List Beast for sale on marketplace
     * @param id ID of Beast
     * @param price Listed price of Beast
     */
    function list(uint256 id, uint256 price) public {
        require(msg.sender == cardContract.ownerOf(id), "Sorry you cannot list Beast as you are not the owner");
        listPrice[id] = price;
    }

    /**
     * @dev Unlist Beast from marketplace
     * @param id ID of Beast
     */
    function unlist(uint256 id) public {
        require(msg.sender == cardContract.ownerOf(id), "Sorry you cannot unlist Beast as you are not the owner");
        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Getter for listed price of Beast on marketplace
     * @param id ID of Beast
     */
    function checkPrice(uint256 id) public view returns(uint) {
        return uint(listPrice[id])*105/100; // Charge 5% commission
    }

    /**
     * @dev Make an offer to listing to purchase Beast
     * @param id ID of Beast
     * @param offerPrice Price of offer for Beast
     */
    function makeOffer(uint256 id, uint256 offerPrice) public {
        require(listPrice[id] != 0, "Beast is not listed for sale");
        require(gemContract.balanceOf(msg.sender) >= offerPrice, "Insufficient Gems");
        require(checkOfferExists(id, address(msg.sender)) == false, "You have already made an offer for this Beast");
        Offer memory newOffer = Offer({
            owner: address(msg.sender),
            offerValue: offerPrice,
            offerCardId: id
        });
        offers[id].push(newOffer);
    }

    /**
     * @dev View the offers for the Beast
     * @param id ID of Beast
     */
    function checkOffers(uint256 id) public view returns(Offer[] memory) {
        require(msg.sender == cardContract.ownerOf(id), "Sorry you cannot view the offers for this Beast as you are not the owner");
        uint256 numOffers = offers[id].length;
        Offer[] memory offerIds = new Offer[](numOffers);
        for (uint i = 0; i < numOffers; i++) {
            Offer storage offer = offers[id][i];
            offerIds[i] = offer;
        }
        return offerIds;
    }

    /**
     * @dev Accept offer made by offerer for Beast
     * @param id ID of Beast
     * @param offerer Address of offerer for the Beast
     */
    function acceptOffer(uint256 id, address offerer) public {
        require(msg.sender == cardContract.ownerOf(id), "Sorry you cannot accept offers for this Beast as you are not the owner");
        require(checkOfferExists(id, offerer) == true, "Offer does not exist");
        uint256 price;

        uint256 numOffers = offers[id].length;
        for (uint i = 0; i < numOffers; i++) {
            if(offers[id][i].owner == offerer) {
                price = offers[id][i].offerValue;
            }
        }

        gemContract.transferGemsFrom(offerer, msg.sender, price);
        gemContract.transferGemsFrom(offerer, address(this), price* 5/100);
        cardContract.safeTransferFrom(msg.sender, offerer, id);

        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Check if an offer exists
     * @param id ID of Beast
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
     * @dev Retract offer that was already made for a Beast
     * @param id ID of Beast
     */
    function retractOffer(uint256 id) public {
        require(checkOfferExists(id, address(msg.sender)) == true, "You have not made an offer for this Beast");
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
     * @dev Buy Beast at listed price
     * @param id ID of Beast
     */
    function buy(uint256 id) public {
        require(listPrice[id] != 0, "Beast is not listed for sale");
        require(gemContract.balanceOf(msg.sender) >= this.checkPrice(id), "Insufficient Gems");

        address recipent = address(uint160(cardContract.ownerOf(id)));
        address seller = recipent;
        gemContract.transferGemsFrom(msg.sender ,recipent, listPrice[id]); // transfer price to seller
        gemContract.transferGemsFrom(msg.sender, address(this), listPrice[id]*5/100); // transfer commission to this contract
        cardContract.safeTransferFrom(seller, address(msg.sender), id);

        listPrice[id] = 0;
        delete offers[id];
    }

    /**
     * @dev Getter for address of owner of contract
     */
    function getContractOwner() public view returns(address) {
        return owner;
    }

    /**
     * @dev Withdraw commission from marketplace to contract owner
     */
    function withdraw() public { 
        require(msg.sender == owner, "Sorry, you are not allowed to do that");
        if(msg.sender == owner) {
            gemContract.transferGems(msg.sender, address(this).balance);
        }
    }
    
    /**
     * @dev Check commission made from marketplace
     */
    function checkCommission() public view returns(uint256) {
        require(msg.sender == owner, "Sorry, you are not allowed to do that");
        return gemContract.checkGemsOf(address(this));
    }
}