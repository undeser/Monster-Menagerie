pragma solidity ^0.5.0;

import "./ERC20.sol"; 

contract Gem {
  ERC20 erc20Contract;
  address owner;
  
  constructor() public {
    ERC20 e = new ERC20();
    erc20Contract = e;
    owner = msg.sender;
  }
  
  // function getCredit() public payable {}
  
  // function checkCredit() public view returns (uint256) {}
  
  // function checkBal(address myAdd) public view returns (uint256) {}
  
  // function transfer(address recipient, uint256 value) public returns (bool) {}

}
