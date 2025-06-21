
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Africa Fast Ferry Ltd Tokenization Contract (AFFEQ + AFFR)
/// @notice Combined equity and revenue tokens for Africa Fast Ferry Ltd
/// @dev Implements key ERC-3643 concepts and compliance controls

contract AfricaFastFerryToken is AccessControl, Pausable {
    // -------------------------------
    // Token Metadata
    // -------------------------------
    string public constant name = "Africa Fast Ferry Ltd Security Tokens";
    string public constant symbolAFFEQ = "AFFEQ";
    string public constant symbolAFFR = "AFFR";
    uint8 public constant decimals = 0;

    // -------------------------------
    // Roles
    // -------------------------------
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");
    bytes32 public constant REVENUE_MANAGER_ROLE = keccak256("REVENUE_MANAGER_ROLE");

    // -------------------------------
    // USDC Token for Payments
    // -------------------------------
    IERC20 public usdcToken;

    // -------------------------------
    // Token Supply
    // -------------------------------
    uint256 public constant totalSupplyAFFEQ = 500_000_000;
    uint256 public constant totalSupplyAFFR = 250_000_000;

    mapping(address => uint256) private affeqBalances;
    mapping(address => uint256) private affrBalances;

    // -------------------------------
    // Compliance and KYC
    // -------------------------------
    mapping(address => bool) public isWhitelisted;

    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender], "KYC not verified");
        _;
    }

    modifier validateTransfer(address from, address to) {
        require(isWhitelisted[to], "Recipient not whitelisted");
        require(isWhitelisted[from], "Sender not whitelisted");
        _;
    }

    // -------------------------------
    // Lockup & Vesting
    // -------------------------------
    uint256 public constant lockupPeriod = 365 days;
    mapping(address => uint256) public vestingStart;
    mapping(address => bool) public isAFFEQVested;

    // -------------------------------
    // Revenue Distribution (USDC)
    // -------------------------------
    mapping(address => uint256) public claimedRevenue;
    uint256 public totalRevenueDistributed;

    // -------------------------------
    // Production Lifecycle
    // -------------------------------
    bool public productionLaunched = false;
    uint256 public launchTimestamp;

    // -------------------------------
    // Events
    // -------------------------------
    event RevenueClaimed(address indexed holder, uint256 amount);
    event AFFEQTransferred(address indexed from, address indexed to, uint256 amount);
    event AFFRTransferred(address indexed from, address indexed to, uint256 amount);
    event ProductionLaunched(uint256 timestamp);
    event RevenueDeposited(uint256 amount);

    // -------------------------------
    // Constructor
    // -------------------------------
    constructor(
        address usdcAddress,
        address[] memory affeqHolders,
        uint256[] memory affeqAmounts,
        address[] memory affrHolders,
        uint256[] memory affrAmounts
    ) {
        require(usdcAddress != address(0), "Invalid USDC address");
        require(affeqHolders.length == affeqAmounts.length, "Mismatch AFFEQ");
        require(affrHolders.length == affrAmounts.length, "Mismatch AFFR");

        usdcToken = IERC20(usdcAddress);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WHITELISTER_ROLE, msg.sender);
        _grantRole(REVENUE_MANAGER_ROLE, msg.sender);

        for (uint256 i = 0; i < affeqHolders.length; i++) {
            affeqBalances[affeqHolders[i]] = affeqAmounts[i];
            vestingStart[affeqHolders[i]] = block.timestamp;
            isAFFEQVested[affeqHolders[i]] = true;
            isWhitelisted[affeqHolders[i]] = true;
        }

        for (uint256 j = 0; j < affrHolders.length; j++) {
            affrBalances[affrHolders[j]] = affrAmounts[j];
            isWhitelisted[affrHolders[j]] = true;
        }
    }

    // -------------------------------
    // Admin & Role Functions
    // -------------------------------
    function setWhitelisted(address investor, bool approved) external onlyRole(WHITELISTER_ROLE) {
        isWhitelisted[investor] = approved;
    }

    function launchProduction() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!productionLaunched, "Already launched");
        productionLaunched = true;
        launchTimestamp = block.timestamp;
        emit ProductionLaunched(launchTimestamp);
    }

    function depositRevenue(uint256 amount) external onlyRole(REVENUE_MANAGER_ROLE) whenNotPaused {
        require(productionLaunched, "Not launched");
        require(amount > 0, "Zero revenue");

        require(usdcToken.transferFrom(msg.sender, address(this), amount), "USDC transfer failed");
        totalRevenueDistributed += amount;
        emit RevenueDeposited(amount);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    // -------------------------------
    // AFFEQ Transfer
    // -------------------------------
    function transferAFFEQ(address to, uint256 amount)
        external
        onlyWhitelisted
        validateTransfer(msg.sender, to)
        whenNotPaused
    {
        require(productionLaunched, "Not live");
        require(block.timestamp >= vestingStart[msg.sender] + lockupPeriod, "Still in lockup");
        require(affeqBalances[msg.sender] >= amount, "Insufficient AFFEQ");

        affeqBalances[msg.sender] -= amount;
        affeqBalances[to] += amount;

        emit AFFEQTransferred(msg.sender, to, amount);
    }

    // -------------------------------
    // AFFR Transfer
    // -------------------------------
    function transferAFFR(address to, uint256 amount)
        external
        onlyWhitelisted
        validateTransfer(msg.sender, to)
        whenNotPaused
    {
        require(productionLaunched, "Not live");
        require(affrBalances[msg.sender] >= amount, "Insufficient AFFR");

        affrBalances[msg.sender] -= amount;
        affrBalances[to] += amount;

        emit AFFRTransferred(msg.sender, to, amount);
    }

    // -------------------------------
    // Revenue Claim (in USDC)
    // -------------------------------
    function claimRevenue() external onlyWhitelisted whenNotPaused {
        require(productionLaunched, "Not live");

        uint256 holderShare = affrBalances[msg.sender];
        require(holderShare > 0, "No AFFR");

        uint256 totalOwed = (totalRevenueDistributed * holderShare) / totalSupplyAFFR;
        uint256 claimable = totalOwed - claimedRevenue[msg.sender];
        require(claimable > 0, "Nothing to claim");

        claimedRevenue[msg.sender] += claimable;
        require(usdcToken.transfer(msg.sender, claimable), "USDC payout failed");

        emit RevenueClaimed(msg.sender, claimable);
    }

    // -------------------------------
    // View Functions
    // -------------------------------
    function balanceOfAFFEQ(address account) external view returns (uint256) {
        return affeqBalances[account];
    }

    function balanceOfAFFR(address account) external view returns (uint256) {
        return affrBalances[account];
    }

    function getClaimableRevenue(address account) external view returns (uint256) {
        uint256 holderShare = affrBalances[account];
        uint256 earned = (totalRevenueDistributed * holderShare) / totalSupplyAFFR;
        return earned - claimedRevenue[account];
    }
}
