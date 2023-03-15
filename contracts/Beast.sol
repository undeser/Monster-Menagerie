// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import './IERC721Receiver.sol';

contract ERC721 {
    string public name;
    string public symbol;
    string public baseURI;

    uint256 public nextTokenIdToMint;
    uint256 public maxTokens;
    address public contractOwner;

    // token id => owner
    mapping(uint256 => address) internal _owners;
    // owner => token count
    mapping(address => uint256) internal _balances;
    // token id => approved address
    mapping(uint256 => address) internal _tokenApprovals;
    // owner => (operator => yes/no)
    mapping(address => mapping(address => bool)) internal _operatorApprovals;
    // token id => token uri
    mapping(uint256 => string) _tokenUris;

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        baseURI = "https://ipfs.io/ipfs/bafybeiel4uozzktij5vgegsmtnh6j46wtj3azuiih5ufwnl5uuh6jwhcia/";
        nextTokenIdToMint = 0;
        maxTokens = 1000;
        contractOwner = msg.sender;
    }

    function balanceOf(address _owner) public view returns(uint256) {
        require(_owner != address(0), "Null address specified");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns(address) {
        return _owners[_tokenId];
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

    function mint() public payable{
        require(msg.value > 100000000000000000, "Not enough Eth supplied");
        _owners[nextTokenIdToMint] = tx.origin;
        _balances[tx.origin] += 1;
        _tokenUris[nextTokenIdToMint] = string.concat(baseURI, "Beast_", uint2str(nextTokenIdToMint), ".json");
        emit Transfer(address(0), tx.origin, nextTokenIdToMint);
        nextTokenIdToMint += 1;
    }

    function tokenURI(uint256 _tokenId) public view returns(string memory) {
        return _tokenUris[_tokenId];
    }

    function totalSupply() public view returns(uint256) {
        return nextTokenIdToMint;
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
