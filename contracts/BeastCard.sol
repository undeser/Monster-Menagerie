// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import './IERC721Receiver.sol';
import './Gem.sol';

contract BeastCard {
    Gem gemContract;
    string public collectionName;
    string public symbol;
    string public baseURI;

    enum cardState { broken, functional }

    uint256 public nextTokenIdToMint;
    uint256 public maxTokens;
    address public contractOwner;

    // card id => owner
    mapping(uint256 => address) internal _owners;
    // owner => card count
    mapping(address => uint256) internal _balances;
    // card id => approved address
    mapping(uint256 => address) internal _tokenApprovals;
    // owner => (operator => yes/no)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    // card id => beast struct
    mapping(uint256 => Beast) _beasts;
    // card id => card state
    mapping(uint256 => cardState) _cardStates;
    // card id => URI
    mapping(uint256 => string) _tokenUris;


    struct Beast {
        uint256 id;
        string name;
        string rarity;
        string nature;
        uint256 cost;
        uint256 attack;
        uint256 health;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(Gem gemAddress, string memory _name, string memory _symbol) {
        gemContract = gemAddress;
        collectionName = _name;
        symbol = _symbol;
        baseURI = "https://ipfs.io/ipfs/bafybeihjukhqan3okv5kpoqh6aqxmncjp75a76rgmm6zet6x3l7kugck5e/";
        nextTokenIdToMint = 0;
        maxTokens = 1000;
        contractOwner = msg.sender;
    }
    
    // Set as public so as to allow Fight.sol to call it
    // Any better way to do it?
    function cardDestroyed(uint256 _cardId) public {
        _cardStates[_cardId] = cardState.broken;
    }

    function cardRevived(uint256 _cardId) internal {
        _cardStates[_cardId] = cardState.functional;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenUris[_tokenId];
    }

    function getName() external view returns (string memory) {
        return collectionName;
    }

    function getSymbol() external view returns (string memory) {
        return symbol;
    }

    function restoreCard(uint256 _cardId) public {
        require(_owners[_cardId] == msg.sender, "Not owner of Beast");
        require(_cardStates[_cardId] == cardState.broken, "Beast is not broken");
        string memory rarity = _beasts[_cardId].rarity;
        if (compareStrings(rarity, "Legendary")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 8);
            cardRevived(_cardId);
        } else if (compareStrings(rarity, "Epic")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 4);
            cardRevived(_cardId);
        } else if (compareStrings(rarity, "Rare")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 2);
            cardRevived(_cardId);
        } else if (compareStrings(rarity, "Common")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 1);
            cardRevived(_cardId);
        }
    }

    function attackOf(uint256 _cardId) public view returns(uint256) {
        return _beasts[_cardId].attack;
    }

    function healthOf(uint256 _cardId) public view returns(uint256) {
        return _beasts[_cardId].health;
    }

    function stateOf(uint256 _cardId) public view returns(cardState) {
        return _cardStates[_cardId];
    }

    function costOf(uint256 _cardId) public view returns (uint256) {
        return _beasts[_cardId].cost;
    }

    function natureOf(uint256 _cardId) public view returns (string memory) {
        return _beasts[_cardId].nature;
    }

    function balanceOf(address _owner) public view returns(uint256) {
        require(_owner != address(0), "Null address specified");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns(address) {
        return _owners[_tokenId];
    }

    function effective(uint256 myCard, uint256 enemyCard) public view returns (bool) {
        string memory myNature = _beasts[myCard].nature;
        string memory enemyNature = _beasts[enemyCard].nature;
        if ((compareStrings(myNature, "Aquatic") && compareStrings(enemyNature, "Infernal")) || (compareStrings(myNature, "Verdant") && compareStrings(enemyNature, "Aquatic")) || (compareStrings(myNature, "Infernal") && compareStrings(enemyNature, "Verdant"))) {
            return true;
        }  else {
            return false;
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable {
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "No approval grant to transfer this Beast");
        _transfer(_from, _to, _tokenId);
        // trigger func check
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "!ERC721Implementer");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        // unsafe transfer without onERC721Received, used for contracts that dont implement
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "No approval grant to transfer this Beast");
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "Not owner of Beast");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }

    function mint(address _to, string memory name, string memory rarity, string memory nature, uint256 cost, uint256 attack, uint256 health) public {
        require(gemContract.balanceOf(_to) > 1, "Not enough Gem in wallet");
        gemContract.transferGemsFrom(_to, address(this), 5);
        _owners[nextTokenIdToMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdToMint] = string.concat(baseURI, "Beast_", uint2str(nextTokenIdToMint), ".json");
        _beasts[nextTokenIdToMint] = Beast(nextTokenIdToMint, name, rarity, nature, cost, attack, health);
        _cardStates[nextTokenIdToMint] = cardState.functional;
        emit Transfer(address(0), _to, nextTokenIdToMint);
        nextTokenIdToMint += 1;
    }

    function totalSupply() public view returns(uint256) {
        return nextTokenIdToMint;
    }

    function withdraw() public {
        uint256 amt = gemContract.checkGems();
        gemContract.giveGemApproval(contractOwner, amt);
        gemContract.transferGemsFrom(address(this), contractOwner, amt);
    }

    // INTERNAL FUNCTIONS
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        // check if to is an contract, if yes, to.code.length will always > 0
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // unsafe transfer
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "Not owner of Beast");
        require(_to != address(0), "Null Address Specified");

        delete _tokenApprovals[_tokenId];
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}
