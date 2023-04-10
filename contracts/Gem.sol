// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC20.sol"; 

/**
 * @title Gem
 * @dev Gem is the ERC20 token used for MonsterMenagerie.
 */
contract Gem is ERC20("GEM", "GM") {
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    /**
     * @dev Sets the values for owner of the contract and supply limit
     */
    constructor() {
        owner = msg.sender;
        supplyLimit = 1000000 * 1000000000000000000;
    }

    /**
     * @dev Mints Gems with ETH
     */
    function getGems() public payable {
        uint256 amt = msg.value * 1000;
        require(totalSupply() + amt < supplyLimit, "Warning: Insufficient Gems!");
        mint(msg.sender, amt);
    }

    /**
     * @dev Getter for amount of gems held by the caller of the function
     */
    function checkGems() public view returns (uint256) {
        return balanceOf(msg.sender) / 1000000000000000000;
    }

    /**
     * @dev Getter for amount of gems held by an address
     * @param user Address of user of interest
     */
    function checkGemsOf(address user) public view returns (uint256) {
        return balanceOf(user) / 1000000000000000000;
    }

    /**
     * @dev Transfer gems from function caller to recipient
     * @param recipient Address of recipient
     * @param value Amount of gems to transfer
     */
    function transferGems(address recipient, uint256 value) public returns (bool) {
        return transfer(recipient, value * 1000000000000000000);
    }

    /**
     * @dev Transfer gems from an address to another address
     * @param from Address of sender
     * @param to Address of recipient
     * @param amt Amount of gems to transfer
     */
    function transferGemsFrom(address from, address to, uint256 amt) public {
        require(allowance(from, msg.sender) > amt * 1000000000000000000, "Warning: You are not allowed to transfer!");
        transferFrom(from, to, amt * 1000000000000000000);
    }

    /**
     * @dev Give an address approval to transfer a specified amount of gems
     * @param recipient Address to be given approval
     * @param amt Amount of gems to be approved to the address
     */
    function giveGemApproval(address recipient, uint256 amt) public {
        approve(recipient, amt * 1000000000000000000);
    }

    /**
     * @dev Check allowance given to spender by the user
     * @param user Address of the owner of the gems
     * @param spender Address of the spender of the gems
     */
    function checkGemAllowance(address user, address spender) public view returns (uint256) {
        return allowance(user, spender) / 1000000000000000000;
    }

    /**
     * @dev Track current total gem supply
     */
    function currentGemSupply() public view returns (uint256) {
        return totalSupply() / 1000000000000000000;
    }
}