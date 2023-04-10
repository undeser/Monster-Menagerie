// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './IERC721Receiver.sol';
import './Gem.sol';

/**
 * @title Beasts
 * @dev Beasts is an ERC721 token that we use to battle each other in our game, to earn Gems.
 */
contract Beasts {
    Gem gemContract;
    string public collectionName;
    string public collectionSymbol;
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
    
    /**
     * @dev Structure to store the properties of each Beast Card
     */
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

    /**
     * @dev Sets the values for gemContract, collectionName, collectionSymbol, baseURI, nextTokenIdToMint, maxTokens and contractOwner
     * @param gemAddress Address of deployed Gem contract
     * @param _name Name of collection
     * @param _symbol Symbol of collection
     */
    constructor(Gem gemAddress, string memory _name, string memory _symbol) {
        gemContract = gemAddress;
        collectionName = _name;
        collectionSymbol = _symbol;
        baseURI = "https://ipfs.io/ipfs/bafybeihjukhqan3okv5kpoqh6aqxmncjp75a76rgmm6zet6x3l7kugck5e/";
        nextTokenIdToMint = 0;
        maxTokens = 1000;
        contractOwner = msg.sender;
    }
    
    /**
     * @dev Destroys Beast Card and sets state to broken
     * @param id ID of Beast Card  
     */
    function cardDestroyed(uint256 id) public {
        require(isContract(), "You cannot destroy cards");
        _cardStates[id] = cardState.broken;
    }

    /**
     * @dev Revives Beast Card and sets state to functional
     * @param id ID of Beast
     */
    function cardRevived(uint256 id) internal {
        _cardStates[id] = cardState.functional;
    }

    /**
     * @dev Revives Beast Card when owner pays a fee
     * @param id ID of Beast Card
     */
    function restoreCard(uint256 id) public {
        require(_owners[id] == msg.sender, "Not owner of Beast Card");
        require(_cardStates[id] == cardState.broken, "Beast Card is not broken");
        string memory rarity = _beasts[id].rarity;
        if (compareStrings(rarity, "Legendary")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 8);
            cardRevived(id);
        } else if (compareStrings(rarity, "Epic")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 4);
            cardRevived(id);
        } else if (compareStrings(rarity, "Rare")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 2);
            cardRevived(id);
        } else if (compareStrings(rarity, "Common")) {
            gemContract.transferGemsFrom(msg.sender, address(this), 1);
            cardRevived(id);
        }
    }

    /**
     * @dev Checks if first Beast is effective on second Beast
     * @param id ID of Beast of interest
     * @param other_id ID of the other Beast in fight
     */
    function effective(uint256 id, uint256 other_id) public view returns (bool) {
        string memory myNature = _beasts[id].nature;
        string memory enemyNature = _beasts[other_id].nature;
        if ((compareStrings(myNature, "Aquatic") && compareStrings(enemyNature, "Infernal")) || (compareStrings(myNature, "Verdant") && compareStrings(enemyNature, "Aquatic")) || (compareStrings(myNature, "Infernal") && compareStrings(enemyNature, "Verdant"))) {
            return true;
        }  else {
            return false;
        }
    }
    
    /**
     * @dev Safe transfer of Beast from one address to another address
     * @param _from Address of current owner of Beast
     * @param _to Address of new owner of Beast
     * @param _tokenId ID of Beast to be transferred
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable {
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "No approval grant to transfer this Beast");
        _transfer(_from, _to, _tokenId);
        // trigger func check
        require(_checkOnERC721Received(_from, _to, _tokenId, _data), "!ERC721Implementer");
    }

    /**
     * @dev Transfer Beast Card from an address to another address
     * @param _from Address of current owner of Beast Card 
     * @param _to Address of new owner of Beast Card
     * @param _tokenId ID of Beast Card being transferred
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable {
        // unsafe transfer without onERC721Received, used for contracts that dont implement
        require(ownerOf(_tokenId) == msg.sender || _tokenApprovals[_tokenId] == msg.sender || _operatorApprovals[ownerOf(_tokenId)][msg.sender], "No approval grant to transfer this Beast");
        _transfer(_from, _to, _tokenId);
    }

    /**
     * @dev Give approval to an address to transfer a Beast Card
     * @param _approved Address that is approved by owner of Beast Card
     * @param _tokenId ID of Beast Card
     */
    function approve(address _approved, uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) == msg.sender, "Not owner of Beast Card");
        _tokenApprovals[_tokenId] = _approved;
        emit Approval(ownerOf(_tokenId), _approved, _tokenId);
    }

    /**
     * @dev Getter for address approved for transfer of a Beast Card
     * @param _tokenId ID of Beast Card
     */
    function getApproved(uint256 _tokenId) public view returns (address) {
        return _tokenApprovals[_tokenId];
    }

    /**
     * @dev Give approval to an address to transfer all Beast Cards owned by user
     * @param _operator Address that is approved by owner
     * @param _approved Boolean of whether operator is approved
     */
    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /**
     * @dev Getter for approval of Beast Card to an address
     * @param _owner Address of owner of Beast Card
     * @param _operator Address being given approval
     */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_owner][_operator];
    }
    
    /**
     * @dev Mint new Beast Card
     * @param _to Address of owner of new Beast Card
     * @param bname Name of Beast Card
     * @param rarity Rarity of Beast Card
     * @param nature Nature of Beast Card
     * @param cost Cost of Beast Card
     * @param attack Attack of Beast Card
     * @param health Health of Beast Card
     */
    function mint(address _to, string memory bname, string memory rarity, string memory nature, uint256 cost, uint256 attack, uint256 health) public {
        require(gemContract.balanceOf(_to) > 1, "Not enough Gem in wallet");
        gemContract.transferGemsFrom(_to, address(this), 5);
        _owners[nextTokenIdToMint] = _to;
        _balances[_to] += 1;
        _tokenUris[nextTokenIdToMint] = string.concat(baseURI, "Beast_", uint2str(nextTokenIdToMint), ".json");
        _beasts[nextTokenIdToMint] = Beast(nextTokenIdToMint, bname, rarity, nature, cost, attack, health);
        _cardStates[nextTokenIdToMint] = cardState.functional;
        emit Transfer(address(0), _to, nextTokenIdToMint);
        nextTokenIdToMint += 1;
    }

    /**
     * @dev Getter that returns the current total supply of cards
     */
    function totalSupply() public view returns(uint256) {
        return nextTokenIdToMint;
    }

    /**
     * @dev Withdraw gems in Beast Cards contract to contract owner 
     */
    function withdraw() public {
        uint256 amt = gemContract.checkGems();
        gemContract.transferGems(contractOwner, amt);
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

    // Unsafe transfer
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from, "Not owner of Beast");
        require(_to != address(0), "Null Address Specified");

        delete _tokenApprovals[_tokenId];
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * Compare two strings whether they are the same
     * @param a String a
     * @param b String b
     */
    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    /**
     * @dev Converts uint to string
     * @param _i uint value of interest
     */
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

    /**
     * @dev Check if msg.sender is a contract
     */
    function isContract() public view returns (bool) {
      uint32 size;
      address a = msg.sender;
      assembly {
        size := extcodesize(a)
      }
      return (size > 0);
    }

    /**
     * @dev Getter for name of collection
     */
    function name() external view returns (string memory) {
        return collectionName;
    }

    /**
     * @dev Getter for symbol of collection
     */
    function symbol() external view returns (string memory) {
        return collectionSymbol;
    }

    /**
     * @dev Getter for URI of Beast Card
     * @param _tokenId ID of Beast Card
     */
    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return _tokenUris[_tokenId];
    }

    /**
     * @dev Getter for attack of Beast Card
     * @param id ID of Beast Card
     */
    function attackOf(uint256 id) public view returns(uint256) {
        return _beasts[id].attack;
    }

    /**
     * @dev Getter for health of Beast Card
     * @param id ID of Beast Card
     */
    function healthOf(uint256 id) public view returns(uint256) {
        return _beasts[id].health;
    }

    /**
     * @dev Getter for state of Beast Card
     * @param id ID of Beast Card
     */
    function stateOf(uint256 id) public view returns(cardState) {
        return _cardStates[id];
    }

    /**
     * @dev Getter for cost of Beast Card
     * @param id ID of Beast Card
     */
    function costOf(uint256 id) public view returns (uint256) {
        return _beasts[id].cost;
    }

    /**
     * @dev Getter for nature of Beast Card
     * @param id ID of Beast Card
     */
    function natureOf(uint256 id) public view returns (string memory) {
        return _beasts[id].nature;
    }

    /**
     * @dev Getter for name of Beast Card
     * @param id ID of Beast Card
     */
    function nameOf(uint256 id) public view returns (string memory) {
        return _beasts[id].name;
    }

    /**
     * @dev Getter for rarity of Beast Card
     * @param id ID of Beast Card
     */
    function rarityOf(uint256 id) public view returns (string memory) {
        return _beasts[id].rarity;
    }

    /**
     * @dev Getter for number of Beast Cards owned by user
     * @param _owner Address of user 
     */
    function balanceOf(address _owner) public view returns(uint256) {
        require(_owner != address(0), "Null address specified");
        return _balances[_owner];
    }

    /**
     * @dev Getter for address of owner of Beast Card
     * @param id ID of Beast Card
     */
    function ownerOf(uint256 id) public view returns(address) {
        return _owners[id];
    }
}
