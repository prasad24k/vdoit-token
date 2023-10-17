// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VDOITTokenICO {
    string public name = "VDOIT Token";
    string public symbol = "VDOIT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    uint256 public coinPrice = 2e17; // 0.2 USDT in wei
    uint256 public hardCap = 1e7 * 1e18; // Maximum supply of 10,000,000 VDOIT
    address public owner;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public minPurchase = 1e19; // 10 USDT in wei
    uint256 public maxPurchase = 2e20; // 200 USDT in 18 wei
    uint256 public claimablePercentage = 10;
    uint256 public totalCollectedUSDT;
    mapping(address => uint256) public balances;

    event TokenPurchased(address indexed buyer, uint256 amount, uint256 usdtAmount);
    event TokensClaimed(address indexed claimer, uint256 amount);
    constructor() {
        owner = msg.sender;
        totalSupply = hardCap;
        balances[owner] = hardCap;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    function setCoinPrice(uint256 _price) external onlyOwner {
        coinPrice = _price;
    }
    function startICO(uint256 _duration) external onlyOwner {
        require(startTime == 0, "ICO has already started");
        startTime = block.timestamp;
        endTime = startTime + _duration;
    }
    function stopICO() external onlyOwner {
        require(startTime > 0, "ICO has not started");
        require(block.timestamp >= endTime, "ICO is still ongoing");
        startTime = 0;
        endTime = 0;
    }
    function purchaseTokens() external payable {
        require(block.timestamp >= startTime, "ICO has not started yet");
        require(block.timestamp <= endTime, "ICO has ended");
        uint256 usdtAmount = msg.value;
        require(usdtAmount >= minPurchase && usdtAmount <= maxPurchase, "Invalid purchase amount");
        uint256 tokenAmount = (usdtAmount * 1e18) / coinPrice;
        require(totalCollectedUSDT + usdtAmount <= hardCap, "ICO hard cap reached");
        balances[msg.sender] += tokenAmount;
        totalCollectedUSDT += usdtAmount;
        emit TokenPurchased(msg.sender, tokenAmount, usdtAmount);
    }
    function claimTokens() external {
        require(block.timestamp >= startTime, "ICO has not started yet");
        require(balances[msg.sender] > 0, "No tokens to claim");
        uint256 claimableAmount = (balances[msg.sender] * claimablePercentage) / 100;
        balances[msg.sender] -= claimableAmount;
        balances[owner] += claimableAmount;
        emit TokensClaimed(msg.sender, claimableAmount);
    }
    function withdrawUSDT() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}
