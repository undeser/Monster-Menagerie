// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./ERC20.sol"; 

/**
 * @title LPtoken
 * @dev LPtoken is the ERC20 token used for staking on the platform to earn rewards.
 */
contract LPtoken is ERC20("BEAST GEM", "BGM") {
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;
    
    /**
     * @dev Sets the values for owner of the contract and supply limit
     */    
    constructor() {
        owner = msg.sender;
        supplyLimit = 1000000 * 1000000000000000000; //No supply limit, this is just to simulate a uniswap LP Token
    }

    /**
     * @dev Mints LPtoken with ETH
     */
    function getLPtoken() public payable {
        uint256 amt = msg.value * 1000 * 1e18;
        // erc.mint(address account, uint256 amount);
        mint(msg.sender, amt);
    }

    /**
     * @dev Getter for amount of LPtokens held by the caller of the function
     */
    function checkLPtoken() public view returns(uint256) {
        return balanceOf(msg.sender) / 1000000000000000000;
    }

    /**
     * @dev Getter for amount of LPtokens held by a certain address
     * @param myAdd Address of user
     */
    function checkLPtokenOf(address myAdd) public view returns (uint256) {
        return balanceOf(myAdd) / 1000000000000000000;
    }

    /**
     * Transfer LPtoken from caller to recipient
     * @param recipient Address of recipient
     * @param value Amount to be transferred
     */
    function transferLPtoken(address recipient, uint256 value) public returns (bool) {
        return transfer(recipient, value * 1000000000000000000);
    }

    /**
     * @dev Transfer LPtoken from an address to another address
     * @param from Address of sender
     * @param to Address of recipient
     * @param amt Amount to be transferred
     */
    function transferLPtokenFrom(address from, address to, uint256 amt) public {
        require(allowance(from, msg.sender) > amt * 1000000000000000000, "Warning: You are not allowed to transfer!");
        transferFrom(from, to, amt * 1000000000000000000);
    }

    /**
     * @dev Give an address approval to transfer a specified amount of LPtokens
     * @param receipt Address to be given approval
     * @param amt Amount of LPtokens to be approved to the address
     */
    function giveLPtokenApproval(address receipt, uint256 amt) public {
        approve(receipt, amt * 1000000000000000000);
    }

    /**
     * @dev Check allowance given to spender by the user
     * @param user Address of the owner of the LPtokens
     * @param spender Address of the spender of the LPtokens
     */
    function checkLPtokenAllowance(address user, address spender) public view returns (uint256) {
        return allowance(user, spender) / 1000000000000000000;
    }

    /**
     * @dev Track current total LPtoken supply
     */
    function currentLPtokenSupply() public view returns (uint256) {
        return totalSupply() / 1000000000000000000;
    }

}