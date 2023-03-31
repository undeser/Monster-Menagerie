// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC20.sol"; 

contract Gem is ERC20("BEAST GEM", "BGM") {
    // ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    constructor() {
        // ERC20 e = new ERC20("Beast Gem", "BGM");
        // erc20Contract = e;
        owner = msg.sender;
        supplyLimit = 1000000 * 1000000000000000000;
    }

    function getGems() public payable {
        uint256 amt = msg.value * 1000;
        require(totalSupply() + amt < supplyLimit, "Warning: Insufficient Gems!");
        // erc.mint(address account, uint256 amount);
        mint(msg.sender, amt);
    }

    function checkGems() public view returns(uint256) {
        return balanceOf(msg.sender) / 1000000000000000000;
    }

    function checkGemsOf(address myAdd) public view returns (uint256) {
        return balanceOf(myAdd) / 1000000000000000000;
    }

    function transferGems(address recipient, uint256 value) public returns (bool) {
        return transfer(recipient, value * 1000000000000000000);
    }

    function transferGemsFrom(address from, address to, uint256 amt) public {
        require(allowance(from, msg.sender) > amt * 1000000000000000000, "Warning: You are not allowed to transfer!");
        transferFrom(from, to, amt * 1000000000000000000);
    }

    function giveGemApproval(address receipt, uint256 amt) public {
        approve(receipt, amt * 1000000000000000000);
    }

    function checkGemAllowance(address user, address spender) public view returns (uint256) {
        return allowance(user, spender) / 1000000000000000000;
    }

    function currentGemSupply() public view returns (uint256) {
        return totalSupply() / 1000000000000000000;
    }

}