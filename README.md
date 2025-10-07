# SecureVault - Professional Smart Contract Testing with Foundry

**Author:** Volodymyr Stetsenko

## Overview

SecureVault is a smart contract project demonstrating professional development and testing practices using Foundry. This contract implements a secure vault where users can deposit and withdraw Ether, following industry best practices for security and gas optimization.

This project serves as a practical example of how to approach smart contract development with a security-first mindset, comprehensive testing, and proper tooling.

## Features

The SecureVault contract includes the following functionality:

- **Deposit & Withdrawal:** Users can securely deposit Ether and withdraw their funds at any time
- **Ownership Management:** Contract owner can transfer ownership to another address
- **Event Logging:** All major actions emit events for transparency and off-chain tracking
- **Custom Errors:** Gas-efficient error handling using custom errors instead of string messages
- **Security Patterns:** Implements Checks-Effects-Interactions pattern to prevent reentrancy attacks
- **Protected Transfers:** Rejects direct ETH transfers to enforce proper deposit flow

## Project Structure

```
SecureVault-Professional/
├── src/
│   └── SecureVault.sol       # Main smart contract
├── test/
│   └── SecureVault.t.sol     # Comprehensive test suite (25 tests)
├── script/
│   ├── Deploy.s.sol          # Deployment script
│   └── Interact.s.sol        # Interaction script
├── lib/
│   └── forge-std/            # Foundry standard library
├── foundry.toml              # Foundry configuration
└── remappings.txt            # Import path remappings
```

## Prerequisites

Before you begin, ensure you have the following installed:

- **Foundry** - The Ethereum development toolkit
- **Git** - For cloning the repository

### Installing Foundry

On Linux or macOS, run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

For Windows users, we recommend using WSL (Windows Subsystem for Linux).

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/VolodymyrStetsenko/foundry-securevault-tutorial.git
cd foundry-securevault-tutorial
```

### 2. Install Dependencies

```bash
forge install
```

### 3. Compile the Contract

```bash
forge build
```

### 4. Run the Tests

```bash
forge test
```

For more detailed output:

```bash
forge test -vv
```

## Testing

The project includes a comprehensive test suite with 25 tests covering:

- ✅ Constructor and initial state verification
- ✅ Successful deposits and withdrawals
- ✅ Multiple user scenarios
- ✅ Error handling and reverts
- ✅ Ownership transfer functionality
- ✅ View functions
- ✅ Fuzz testing with random inputs (256 runs per test)
- ✅ Invariant testing (totalDeposits == contract balance)
- ✅ Integration tests with external contracts
- ✅ Attack simulation (reverting receiver)

### Test Results

All tests pass successfully with excellent coverage:

- **Total Tests:** 25
- **Passed:** 25
- **Failed:** 0
- **Coverage:** ~94% lines, ~97% statements, 100% branches

### Running Coverage Analysis

```bash
forge coverage
```

### Generating Gas Reports

```bash
forge test --gas-report
```

## Deployment

### Local Deployment (Anvil)

1. Start a local Ethereum node:

```bash
anvil
```

2. In a new terminal, set your private key (use one from Anvil's output):

```bash
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```

3. Deploy the contract:

```bash
forge script script/Deploy.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
```

4. Copy the deployed contract address from the output and set it:

```bash
export VAULT_ADDRESS=0x5FbDB2315678afecb367f032d93F642f64180aa3
```

### Interacting with the Contract

Using the interaction script:

```bash
forge script script/Interact.s.sol:InteractWithVault --rpc-url http://127.0.0.1:8545 --broadcast
```

Using Cast (manual commands):

```bash
# Check balance
cast call $VAULT_ADDRESS "getUserBalance(address)" $YOUR_ADDRESS --rpc-url http://127.0.0.1:8545

# Make a deposit
cast send $VAULT_ADDRESS "deposit()" --value 0.1ether --private-key $PRIVATE_KEY --rpc-url http://127.0.0.1:8545

# Withdraw funds
cast send $VAULT_ADDRESS "withdraw(uint256)" 0.05ether --private-key $PRIVATE_KEY --rpc-url http://127.0.0.1:8545
```

## Contract Functions

### Core Functions

- `deposit()` - Deposit Ether into the vault (payable)
- `withdraw(uint256 amount)` - Withdraw your deposited funds
- `transferOwnership(address newOwner)` - Transfer contract ownership (owner only)

### View Functions

- `getContractBalance()` - Returns the total contract balance
- `getUserBalance(address user)` - Returns a specific user's balance
- `owner()` - Returns the current owner address
- `totalDeposits()` - Returns the total amount deposited

## Security Considerations

This contract demonstrates several security best practices:

1. **Custom Errors:** More gas-efficient than string error messages
2. **Checks-Effects-Interactions Pattern:** State changes before external calls to prevent reentrancy
3. **Access Control:** Owner-only functions protected by modifiers
4. **Input Validation:** Zero amount and zero address checks
5. **Event Emission:** All state changes emit events for transparency
6. **Protected Receive:** Rejects direct ETH transfers to enforce proper flow

### ⚠️ Important Disclaimer

**This code is for educational purposes only.** It has not undergone a formal security audit and should **NOT** be used in production environments without a professional security audit.

## Gas Optimization

The contract uses several gas optimization techniques:

- Solidity optimizer enabled (200 runs)
- Custom errors instead of require strings
- Efficient storage patterns
- Minimal external calls

## Learning Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)
- [Smart Contract Security Best Practices](https://consensys.github.io/smart-contract-best-practices/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Volodymyr Stetsenko**

Web3 Developer | Smart Contract Security Enthusiast

---

*If you found this project helpful, please consider giving it a star ⭐ on GitHub!*
