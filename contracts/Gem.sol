pragma solidity ^0.5.0;

import "./ERC20.sol"; 

contract Gem {
    ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
    }

    function getCredit() public payable {
        uint256 amt = msg.value / 10000000000000000; //???
        require(erc20Contract.totalSupply() + amt < supplyLimit, "Warning: Insufficient Gems!");
        // erc.mint(address account, uint256 amount);
        erc20Contract.mint(msg.sender, amt);
    }

    function checkCredit() public view returns(uint256) {
        // erc.balanceOf(address account);
        return erc20Contract.balanceOf(msg.sender);
    }

    function checkBal(address myAdd) public view returns (uint256) {
        // erc.balanceOf(address account);
        return erc20Contract.balanceOf(myAdd);
    }

    function transfer(address recipient, uint256 value) public returns (bool) {
        // erc.transfer(address to, uint256 amount);
        return erc20Contract.transfer(recipient, value);
    }

}
