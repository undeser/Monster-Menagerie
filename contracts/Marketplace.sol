pragma solidity ^0.5.0;

import "./Gem.sol";
import "./BeastCard.sol";

contract Marketplace {
    BeastCard CardContract;
    Gem GemContract;
    //uint256 public comissionFee;
    address _owner = msg.sender;

    struct offer {
        address owner;
        uint256 offerValue;
        uint256 offerCardId;
        uint256 offerID;
    }

    mapping(uint256 => uint256) listPrice;
    mapping(uint256 => offer[]) offers;

        constructor(BeastCard CardContract, Gem GemContract) public {
            CardContract = CardContract;
            GemContract = GemContract;
        }

    function list(uint256 cardID, uint256 price) public {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot list this card as you are not the owner");
        listPrice[cardID] = price;
        offers[cardID] = new offer[];
    }

    function unlist(uint256 cardID) public {
        require(msg.sender == CardContract.ownerOf(cardID), "Sorry you cannot list this card as you are not the owner");
        listPrice[cardID] = 0;
    }

    function checkPrice(uint256 cardID) public view returns(uint256) {
        return listPrice[cardID]*1.05; // Charge 5% commission
    }

    function offer(uint256 cardID, uint256 offerPrice) public {
        require(listPrice[cardID] != 0, "Card is not listed for sale");
        offers[cardID].push(new offer({
            owner: address(msg.sender),
            offerValue: offerPrice,
            offerCardId: cardID,
            offerID:len(offers[cardID])
        }));
    }

    function buy(uint256 cardID) public {
        require(listPrice[cardID] != 0, "Card is not listed for sale");
        require(GemContract.checkCredit(msg.sender) >= this.checkPrice(cardID), "Insufficient Gems");

        address recipent = address(uint160(CardContract.ownerOf(cardID)));
        address seller = recipent;
        GemContract.transfer(recipent, listPrice[cardID]); // transfer price to seller
        GemContract.transfer(address(this), listPrice[cardID]*0.05); // transfer commission to this contract
        CardContract.safeTransferFrom(seller, address(msg.sender), cardID);
    }

    function getContractOwner() public view returns(address) {
        return _owner;
    }

    function withDraw() public { // Withdraw commission
        require(msg.sender == _owner, "Sorry, you are not allowed to do that");
        if(msg.sender == _owner) {
            msg.sender.transfer(address(this).balance);
        }
    }
}