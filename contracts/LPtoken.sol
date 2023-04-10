// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC20.sol"; 

contract LPtoken is ERC20("BEAST GEM", "BGM") {
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    constructor() {
        owner = msg.sender;
        supplyLimit = 1000000 * 1000000000000000000; //No supply limit, this is just to simulate a uniswap LP Token
    }

    function getLPtoken() public payable {
        uint256 amt = msg.value * 1000 * 1e18;
        // erc.mint(address account, uint256 amount);
        mint(msg.sender, amt);
    }

    function checkLPtoken() public view returns(uint256) {
        return balanceOf(msg.sender) / 1000000000000000000;
    }

    function checkLPtokenOf(address myAdd) public view returns (uint256) {
        return balanceOf(myAdd) / 1000000000000000000;
    }

    function transferLPtoken(address recipient, uint256 value) public returns (bool) {
        return transfer(recipient, value * 1000000000000000000);
    }

    function transferLPtokenFrom(address from, address to, uint256 amt) public {
        require(allowance(from, msg.sender) > amt * 1000000000000000000, "Warning: You are not allowed to transfer!");
        transferFrom(from, to, amt * 1000000000000000000);
    }

    function giveLPtokenApproval(address receipt, uint256 amt) public {
        approve(receipt, amt * 1000000000000000000);
    }

    function checkLPtokenAllowance(address user, address spender) public view returns (uint256) {
        return allowance(user, spender) / 1000000000000000000;
    }

    function currentLPtokenSupply() public view returns (uint256) {
        return totalSupply() / 1000000000000000000;
    }

}