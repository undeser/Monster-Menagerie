// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// import "./Gem.sol";
// import "./BeastCard.sol";

// contract Marketplace {
//     BeastCard CardContract;
//     Gem GemContract;
//     //uint256 public comissionFee;
//     address _owner = msg.sender;

//     struct Offer {
//         address owner;
//         uint256 offerValue;
//         uint256 offerCardId;
//     }

//     mapping(uint256 => uint256) listPrice;
//     mapping(uint256 => Offer[]) offers;

//         constructor(BeastCard CardContract, Gem GemContract) public {
//             CardContract = CardContract;
//             GemContract = GemContract;
//         }

//     function list(uint256 cardID, uint256 price) public {
//         require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot list this card as you are not the owner");
//         listPrice[cardID] = price;
//         offers[cardID] = new Offer[];
//     }

//     function unlist(uint256 cardID) public {
//         require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot list this card as you are not the owner");
//         listPrice[cardID] = 0;
//     }

//     function checkPrice(uint256 cardID) public view returns(uint256) {
//         return listPrice[cardID]*1.05; // Charge 5% commission
//     }

//     function offer(uint256 cardID, uint256 offerPrice) public {
//         require(listPrice[cardID] != 0, "Card is not listed for sale");
//         require(GemContract.checkCredit() >= offerPrice, "Insufficient Gems");
//         offers[cardID].push(new offer({
//             owner: address(msg.sender),
//             offerValue: offerPrice,
//             offerCardId: cardID
//         }));
//     }

//     function checkOffers(uint256 cardID) public view returns(offer[] memory) {
//         require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot view the offers for this card as you are not the owner");
//         uint256 numOffers = len(offers[cardID]);
//         Offer[] memory id = new Offer[](numOffers);
//         for (uint i = 0; i < numOffers; i++) {
//             Offer storage offer = offers[cardID][i];
//             id[i] = offer;
//         }
//         return id;
//     }

//     function acceptOffer(uint256 cardID, address offerer) public {
//         require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot accept offers for this card as you are not the owner");
//         require(this.checkOfferExists(cardID, offerer) == true, "Offer does not exists");
        
//         address recipent = address(uint160(CardContract.ownerOf(cardID)));
//         address seller = recipent;
//         uint256 price;

//         uint256 numOffers = len(offers[cardID]);
//         for (uint i = 0; i < numOffers; i++) {
//             Offer storage offer = offerArray[i];
//             if(offer.owner == offerer) {
//                 price = offer.offerValue;
//             }
//         }

//         GemContract.transferFrom(offerer, seller, price);
//         GemContract.transferFrom(offerer, address(this), price*0.05);
//         CardContract.safeTransferFrom(seller, offerer, cardID);

//         offers[cardID] = new Offer[];
//         listPrice[cardID] = 0;
//     }

//     function checkOfferExists(uint256 cardID, address offerer) private view returns(bool) {
//         Offer[] offerArray = offers[cardID];
//         uint256 numOffers = len(offers[cardID]);
//         for (uint i = 0; i < numOffers; i++) {
//             Offer storage offer = offerArray[i];
//             if(offer.owner == Offerer) {
//                 return true;
//             }
//         }
//     }
    
//     function remove(uint index, Offer[] offers) public {
//         offers[index] = offers[offers.length - 1];
//         offers.pop();
//     }

//     function retractOffer(cardID) public {
//         require(this.checkOfferExists(cardID, address(msg.sender)) == true, "Offer does not exists");
//         Offer[] offerArray = offers[cardID];
//         address Offerer = address(msg.sender);
//         uint256 numOffers = len(offers[cardID]);
//         for (uint i = 0; i < numOffers; i++) {
//             Offer storage offer = offerArray[i];
//             if(offer.owner == Offerer) {
//                 offers[cardID].remove(i, offerArray);
//             }
//         }
//     }

//     function buy(uint256 cardID) public {
//         require(listPrice[cardID] != 0, "Card is not listed for sale");
//         require(GemContract.checkCredit() >= this.checkPrice(cardID), "Insufficient Gems");

//         address recipent = address(uint160(CardContract.ownerOf(cardID)));
//         address seller = recipent;
//         GemContract.transfer(recipent, listPrice[cardID]); // transfer price to seller
//         GemContract.transfer(address(this), listPrice[cardID]*0.05); // transfer commission to this contract
//         CardContract.safeTransferFrom(seller, address(msg.sender), cardID);

//         offers[cardID] = new Offer[];
//         listPrice[cardID] = 0;
//     }

//     function getContractOwner() public view returns(address) {
//         return _owner;
//     }

//     function withDraw() public { // Withdraw commission
//         require(msg.sender == _owner, "Sorry, you are not allowed to do that");
//         if(msg.sender == _owner) {
//             msg.sender.transfer(address(this).balance);
//         }
//     }
// }