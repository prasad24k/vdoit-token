// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VDOITToken {
    string public name = "VDOIT TOKEN";
    string public symbol = "VDOIT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 100000 * 10**uint256(decimals);
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => uint256) public lockedBalance;
    uint256 public releaseStartDate;
    uint256 public releaseInterval = 30 days;
    uint256 public releaseAmount = 100 * 10**uint256(decimals);
    uint256 public totalLockedAmount;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Lock(address indexed locker, address indexed locked, uint256 value);
    event Unlock(address indexed locker, address indexed locked, uint256 value);
    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        releaseStartDate = block.timestamp;
        totalLockedAmount = 0;
    }
    function transfer(address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }
    function approve(address spender, uint256 value) public returns (bool success) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(from != address(0) && to != address(0), "Invalid address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Allowance exceeded");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    function burn(uint256 value) public returns (bool success) {
        require(balanceOf[msg.sender] >= value, "Insufficient balance");
        balanceOf[msg.sender] -= value;
        totalSupply -= value;
        emit Burn(msg.sender, value);
        return true;
    }
    function mint(uint256 value) public {
        require(msg.sender == owner, "Only the owner can mint");
        totalSupply += value;
        balanceOf[msg.sender] += value;
        emit Mint(msg.sender, value);
    }
    function lock(address locked, uint256 value) public {
        require(msg.sender == owner, "Only the owner can lock tokens");
        require(balanceOf[locked] >= value, "Insufficient balance to lock");
        balanceOf[locked] -= value;
        lockedBalance[locked] += value;
        totalLockedAmount += value;
        emit Lock(msg.sender, locked, value);
    }
    function unlock(address locked, uint256 value) public {
        require(msg.sender == owner, "Only the owner can unlock tokens");
        require(lockedBalance[locked] >= value, "Insufficient locked balance to unlock");
        lockedBalance[locked] -= value;
        totalLockedAmount -= value;
        emit Unlock(msg.sender, locked, value);
    }
    function releaseTokens() public {
        require(msg.sender == owner, "Only the owner can release tokens");
        require(block.timestamp >= releaseStartDate, "Tokens are still locked");
        require(totalLockedAmount >= releaseAmount, "Insufficient locked tokens");
        balanceOf[owner] += releaseAmount;
        totalSupply += releaseAmount;
        totalLockedAmount -= releaseAmount;
        emit Mint(owner, releaseAmount);
    }
}
