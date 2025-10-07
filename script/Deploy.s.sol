// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {SecureVault} from "../src/SecureVault.sol";

/// @title Deploy SecureVault Script
/// @author Volodymyr Stetsenko
/// @notice Script for deploying the SecureVault contract
/// @dev Works with both local Anvil and remote networks (e.g., Sepolia)
contract DeploySecureVault is Script {
    /// @notice Deploys the SecureVault contract
    /// @dev Uses PRIVATE_KEY from environment variables
    /// @return vault The deployed SecureVault contract instance
    function run() external returns (SecureVault vault) {
        // Get the deployer's private key from environment
        // For Anvil: use one of the default private keys
        // For testnet/mainnet: use your actual private key (NEVER commit this!)
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerKey);
        
        // Deploy the SecureVault contract
        vault = new SecureVault();
        
        // Stop broadcasting
        vm.stopBroadcast();
        
        // Log the deployed address
        console2.log("SecureVault deployed at:", address(vault));
        console2.log("Deployer address:", vm.addr(deployerKey));
    }
}
