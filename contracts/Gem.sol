// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC20.sol"; 

contract Gem {
    ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    constructor() {
        ERC20 e = new ERC20("Beast Gem", "BGM");
        erc20Contract = e;
        owner = msg.sender;
    }

    function getCredit() public payable {
        uint256 amt = msg.value / 1000000000000000; //???
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

    function transferFrom(address from, address to, uint256 amt) public {
        // function transferFrom(address from, address to, uint256 amount)
        require(erc20Contract.allowance(from, msg.sender) > amt, "Warning: You are not allowed to transfer!");
        erc20Contract.transferFrom(from, to, amt);
    }

    function giveApproval(address receipt, uint256 amt) public {
        // function approve(address spender, uint256 amount)
        erc20Contract.approve(receipt, amt);
    }

    function checkAllowance(address user, address spender) public view returns (uint256) {
        // function allowance(address owner, address spender) external view returns (uint256);
        return erc20Contract.allowance(user, spender);
    }

}
