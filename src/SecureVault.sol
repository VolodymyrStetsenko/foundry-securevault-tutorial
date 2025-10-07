// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SecureVault - A simple smart contract for storing and managing funds
/// @author Volodymyr Stetsenko
/// @notice This contract demonstrates basic security principles and testing practices
/// @dev For educational purposes only. DO NOT use in production without a professional audit!
contract SecureVault {
    // ============ State Variables ============
    
    /// @notice The address of the contract owner
    address public owner;
    
    /// @notice Mapping to track user balances
    mapping(address => uint256) public balances;
    
    /// @notice The total amount of deposits in the contract
    uint256 public totalDeposits;
    
    // ============ Events ============
    
    /// @notice Emitted when a user deposits funds
    /// @param user The address of the user making the deposit
    /// @param amount The amount of ETH deposited
    event Deposit(address indexed user, uint256 amount);
    
    /// @notice Emitted when a user withdraws funds
    /// @param user The address of the user making the withdrawal
    /// @param amount The amount of ETH withdrawn
    event Withdrawal(address indexed user, uint256 amount);
    
    /// @notice Emitted when ownership is transferred
    /// @param previousOwner The address of the previous owner
    /// @param newOwner The address of the new owner
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // ============ Errors ============
    
    /// @notice Thrown when a non-owner tries to call an owner-only function
    error NotOwner();
    
    /// @notice Thrown when trying to deposit or withdraw zero amount
    error ZeroAmount();
    
    /// @notice Thrown when trying to withdraw more than the available balance
    error InsufficientBalance();
    
    /// @notice Thrown when trying to transfer ownership to the zero address
    error ZeroAddress();
    
    /// @notice Thrown when ETH transfer via call() fails
    error TransferFailed();
    
    // ============ Modifiers ============
    
    /// @notice Restricts function access to the contract owner only
    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    // ============ Constructor ============
    
    /// @notice Initializes the contract and sets the deployer as the owner
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }
    
    // ============ Receive/Fallback ============
    
    /// @notice Reject plain ETH transfers and force using deposit() function
    /// @dev This ensures all deposits go through the proper deposit() function
    receive() external payable {
        revert("Use deposit() function");
    }
    
    /// @notice Reject any calls to non-existent functions
    fallback() external payable {
        revert("Use deposit() function");
    }
    
    // ============ External Functions ============
    
    /// @notice Allows users to deposit ETH into the vault
    /// @dev Updates user balance and total deposits, then emits an event
    function deposit() external payable {
        if (msg.value == 0) revert ZeroAmount();
        
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }
    
    /// @notice Allows users to withdraw their deposited ETH
    /// @dev Follows Checks-Effects-Interactions pattern to prevent reentrancy
    /// @param amount The amount of ETH to withdraw
    function withdraw(uint256 amount) external {
        // Checks
        if (amount == 0) revert ZeroAmount();
        if (balances[msg.sender] < amount) revert InsufficientBalance();
        
        // Effects (update state before external call)
        balances[msg.sender] -= amount;
        totalDeposits -= amount;
        
        // Interactions (external call last)
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
        
        emit Withdrawal(msg.sender, amount);
    }
    
    /// @notice Transfers ownership of the contract to a new owner
    /// @dev Only the current owner can call this function
    /// @param newOwner The address of the new owner
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        
        address previousOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(previousOwner, newOwner);
    }
    
    // ============ View Functions ============
    
    /// @notice Returns the total ETH balance held by the contract
    /// @return The contract's ETH balance in wei
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /// @notice Returns the deposited balance of a specific user
    /// @param user The address of the user to query
    /// @return The user's balance in wei
    function getUserBalance(address user) external view returns (uint256) {
        return balances[user];
    }
}
