// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {SecureVault} from "../src/SecureVault.sol";

/// @title Interact with SecureVault Script
/// @author Volodymyr Stetsenko
/// @notice Script for interacting with a deployed SecureVault contract
/// @dev Demonstrates deposit, withdrawal, and balance checking
contract InteractWithVault is Script {
    /// @notice Interacts with the deployed SecureVault contract
    /// @dev Requires PRIVATE_KEY and VAULT_ADDRESS environment variables
    function run() external {
        // Get configuration from environment
        uint256 userKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        
        // Connect to the deployed vault
        SecureVault vault = SecureVault(payable(vaultAddress));
        
        address user = vm.addr(userKey);
        
        console2.log("=== SecureVault Interaction ===");
        console2.log("Vault address:", vaultAddress);
        console2.log("User address:", user);
        console2.log("");
        
        // Check initial balances
        console2.log("Initial user balance in vault:", vault.getUserBalance(user));
        console2.log("Initial total deposits:", vault.totalDeposits());
        console2.log("Initial contract balance:", vault.getContractBalance());
        console2.log("");
        
        // Start broadcasting transactions
        vm.startBroadcast(userKey);
        
        // Example 1: Deposit 1 ETH
        console2.log("Depositing 1 ETH...");
        vault.deposit{value: 1 ether}();
        
        // Stop broadcasting to check balances
        vm.stopBroadcast();
        
        console2.log("After deposit:");
        console2.log("User balance in vault:", vault.getUserBalance(user));
        console2.log("Total deposits:", vault.totalDeposits());
        console2.log("Contract balance:", vault.getContractBalance());
        console2.log("");
        
        // Example 2: Withdraw 0.5 ETH
        vm.startBroadcast(userKey);
        
        console2.log("Withdrawing 0.5 ETH...");
        vault.withdraw(0.5 ether);
        
        vm.stopBroadcast();
        
        console2.log("After withdrawal:");
        console2.log("User balance in vault:", vault.getUserBalance(user));
        console2.log("Total deposits:", vault.totalDeposits());
        console2.log("Contract balance:", vault.getContractBalance());
        console2.log("");
        
        console2.log("=== Interaction Complete ===");
    }
    
    /// @notice Demonstrates checking vault information without transactions
    /// @dev Only requires VAULT_ADDRESS environment variable
    function checkVaultInfo() external view {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        SecureVault vault = SecureVault(payable(vaultAddress));
        
        console2.log("=== Vault Information ===");
        console2.log("Vault address:", vaultAddress);
        console2.log("Owner:", vault.owner());
        console2.log("Total deposits:", vault.totalDeposits());
        console2.log("Contract balance:", vault.getContractBalance());
    }
}
