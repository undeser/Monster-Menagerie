// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Gem.sol";
import "./Beasts.sol";

contract Menagerie {
    Beasts CardContract;
    Gem GemContract;
    //uint256 public comissionFee;
    address _owner = msg.sender;

    struct Offer {
        address owner;
        uint256 offerValue;
        uint256 offerCardId;
    }

    mapping(uint256 => uint256) listPrice;
    mapping(uint256 => Offer[]) offers;

    constructor(Beasts beastAddress, Gem gemAddress) {
        CardContract = beastAddress;
        GemContract = gemAddress;
    }

    function list(uint256 cardID, uint256 price) public {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot list this card as you are not the owner");
        listPrice[cardID] = price;
        //offers[cardID] = new Offer[];
    }

    function unlist(uint256 cardID) public {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot unlist this card as you are not the owner");
        listPrice[cardID] = 0;
        delete offers[cardID];
    }

    function checkPrice(uint256 cardID) public view returns(uint) {
        return uint(listPrice[cardID])*105/100; // Charge 5% commission
    }

    function makeOffer(uint256 cardID, uint256 offerPrice) public {
        require(listPrice[cardID] != 0, "Card is not listed for sale");
        require(GemContract.balanceOf(msg.sender) >= offerPrice, "Insufficient Gems");
        require(checkOfferExists(cardID, address(msg.sender)) == false, "You have already made an offer for this card");
        Offer memory newOffer = Offer({
            owner: address(msg.sender),
            offerValue: offerPrice,
            offerCardId: cardID
        });
        offers[cardID].push(newOffer);
    }

    function checkOffers(uint256 cardID) public view returns(Offer[] memory) {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot view the offers for this card as you are not the owner");
        uint256 numOffers = offers[cardID].length;
        Offer[] memory id = new Offer[](numOffers);
        for (uint i = 0; i < numOffers; i++) {
            Offer storage offer = offers[cardID][i];
            id[i] = offer;
        }
        return id;
    }

    function acceptOffer(uint256 cardID, address offerer) public {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot accept offers for this card as you are not the owner");
        require(checkOfferExists(cardID, offerer) == true, "Offer does not exists");
        uint256 price;

        uint256 numOffers = offers[cardID].length;
        for (uint i = 0; i < numOffers; i++) {
            if(offers[cardID][i].owner == offerer) {
                price = offers[cardID][i].offerValue;
            }
        }

        GemContract.transferGemsFrom(offerer, msg.sender, price);
        GemContract.transferGemsFrom(offerer, address(this), price* 5/100);
        CardContract.safeTransferFrom(msg.sender, offerer, cardID);

        listPrice[cardID] = 0;
        delete offers[cardID];
    }

    function checkOfferExists(uint256 cardID, address offerer) public view returns(bool exists) {
        // Offer[] offerArray = offers[cardID];
        uint256 numOffers = offers[cardID].length;
        for (uint i = 0; i < numOffers; i++) {
            // Offer storage offer = offerArray[i];
            if(offers[cardID][i].owner == offerer) {
                exists = true;
                return exists;
            }
        }
    }
    
    /*
    function remove(uint index, Offer[] array) public {
        array[index] = array[array.length - 1];
        array.pop();
    }
    */

    function retractOffer(uint256 cardID) public {
        require(checkOfferExists(cardID, address(msg.sender)) == true, "You have not made an offer for this card");
        // Offer[] offerArray = offers[cardID];
        address Offerer = address(msg.sender);
        uint256 numOffers = offers[cardID].length;
        for (uint i = 0; i < numOffers; i++) {
            // Offer storage offer = offerArray[i];
            if(offers[cardID][i].owner == Offerer) {
                // remove(i, offers[cardID]);
                offers[cardID][i] = offers[cardID][numOffers - 1];
                offers[cardID].pop();
            }
        }
    }

    function buy(uint256 cardID) public {
        require(listPrice[cardID] != 0, "Card is not listed for sale");
        require(GemContract.balanceOf(msg.sender) >= this.checkPrice(cardID), "Insufficient Gems");

        address recipent = address(uint160(CardContract.ownerOf(cardID)));
        address seller = recipent;
        GemContract.transferGemsFrom(msg.sender ,recipent, listPrice[cardID]); // transfer price to seller
        GemContract.transferGemsFrom(msg.sender, address(this), listPrice[cardID]*5/100); // transfer commission to this contract
        CardContract.safeTransferFrom(seller, address(msg.sender), cardID);

        listPrice[cardID] = 0;
        delete offers[cardID];
    }

    function getContractOwner() public view returns(address) {
        return _owner;
    }

    function withDraw() public { // Withdraw commission
        require(msg.sender == _owner, "Sorry, you are not allowed to do that");
        uint256 balance = GemContract.checkGemsOf(address(this));
        if(msg.sender == _owner) {
            GemContract.transferGems(msg.sender, balance);
        }
    }

    function checkCommission() public view returns(uint256) {
        require(msg.sender == _owner, "Sorry, you are not allowed to do that");
        return GemContract.checkGemsOf(address(this));
    }
}