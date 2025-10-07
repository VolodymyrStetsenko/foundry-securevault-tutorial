// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SecureVault.sol";

/// @title SecureVault Test Suite
/// @author Volodymyr Stetsenko
/// @notice Comprehensive tests for the SecureVault contract
contract SecureVaultTest is Test {
    // ============ State Variables ============
    
    SecureVault public vault;
    address public owner;
    address public user1;
    address public user2;
    
    // ============ Events (for testing) ============
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // ============ Setup Function ============
    
    /// @notice setUp() is called before each test
    /// @dev This ensures each test starts with a clean state
    function setUp() public {
        // Create test addresses
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy a new instance of the contract
        vault = new SecureVault();
        
        // Give users test funds
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }
    
    // ============ Constructor Tests ============
    
    /// @notice Test that the owner is set correctly on deployment
    function test_OwnerIsSetCorrectly() public view {
        assertEq(vault.owner(), owner, "Owner should be the deployer");
    }
    
    /// @notice Test that the initial state of the contract is correct
    function test_InitialStateIsCorrect() public view {
        assertEq(vault.totalDeposits(), 0, "Initial total deposits should be 0");
        assertEq(vault.getContractBalance(), 0, "Initial contract balance should be 0");
    }
    
    // ============ Deposit Tests ============
    
    /// @notice Test successful deposit
    function test_DepositSuccessfully() public {
        uint256 depositAmount = 1 ether;
        
        // Expect the Deposit event to be emitted
        vm.expectEmit(true, false, false, true);
        emit Deposit(user1, depositAmount);
        
        // Execute deposit as user1
        vm.prank(user1);
        vault.deposit{value: depositAmount}();
        
        // Verify balances are updated
        assertEq(vault.getUserBalance(user1), depositAmount, "User balance should be updated");
        assertEq(vault.totalDeposits(), depositAmount, "Total deposits should be updated");
        assertEq(vault.getContractBalance(), depositAmount, "Contract balance should be updated");
    }
    
    /// @notice Test multiple deposits from the same user
    function test_MultipleDepositsFromSameUser() public {
        uint256 firstDeposit = 1 ether;
        uint256 secondDeposit = 2 ether;
        
        vm.startPrank(user1);
        vault.deposit{value: firstDeposit}();
        vault.deposit{value: secondDeposit}();
        vm.stopPrank();
        
        assertEq(vault.getUserBalance(user1), firstDeposit + secondDeposit);
        assertEq(vault.totalDeposits(), firstDeposit + secondDeposit);
    }
    
    /// @notice Test deposits from multiple users
    function test_DepositsFromMultipleUsers() public {
        uint256 amount1 = 1 ether;
        uint256 amount2 = 2 ether;
        
        vm.prank(user1);
        vault.deposit{value: amount1}();
        
        vm.prank(user2);
        vault.deposit{value: amount2}();
        
        assertEq(vault.getUserBalance(user1), amount1);
        assertEq(vault.getUserBalance(user2), amount2);
        assertEq(vault.totalDeposits(), amount1 + amount2);
    }
    
    /// @notice Test that depositing zero amount reverts
    function test_RevertWhen_DepositZeroAmount() public {
        vm.prank(user1);
        vm.expectRevert(SecureVault.ZeroAmount.selector);
        vault.deposit{value: 0}();
    }
    
    /// @notice Test that sending ETH directly to the contract reverts
    function test_RevertWhen_SendingETHDirectly() public {
        vm.prank(user1);
        vm.expectRevert("Use deposit() function");
        (bool success,) = address(vault).call{value: 1 ether}("");
        success; // Silence unused variable warning
    }
    
    // ============ Withdrawal Tests ============
    
    /// @notice Test successful withdrawal
    function test_WithdrawSuccessfully() public {
        uint256 depositAmount = 5 ether;
        uint256 withdrawAmount = 2 ether;
        
        // First make a deposit
        vm.prank(user1);
        vault.deposit{value: depositAmount}();
        
        // Store initial balance
        uint256 initialBalance = user1.balance;
        
        // Expect the Withdrawal event to be emitted
        vm.expectEmit(true, false, false, true);
        emit Withdrawal(user1, withdrawAmount);
        
        // Withdraw funds
        vm.prank(user1);
        vault.withdraw(withdrawAmount);
        
        // Verify results
        assertEq(vault.getUserBalance(user1), depositAmount - withdrawAmount);
        assertEq(vault.totalDeposits(), depositAmount - withdrawAmount);
        assertEq(user1.balance, initialBalance + withdrawAmount);
    }
    
    /// @notice Test withdrawing full balance
    function test_WithdrawFullBalance() public {
        uint256 depositAmount = 3 ether;
        
        vm.startPrank(user1);
        vault.deposit{value: depositAmount}();
        vault.withdraw(depositAmount);
        vm.stopPrank();
        
        assertEq(vault.getUserBalance(user1), 0);
        assertEq(vault.totalDeposits(), 0);
    }
    
    /// @notice Test that withdrawing zero amount reverts
    function test_RevertWhen_WithdrawZeroAmount() public {
        vm.prank(user1);
        vault.deposit{value: 1 ether}();
        
        vm.prank(user1);
        vm.expectRevert(SecureVault.ZeroAmount.selector);
        vault.withdraw(0);
    }
    
    /// @notice Test that withdrawing more than balance reverts
    function test_RevertWhen_InsufficientBalance() public {
        vm.prank(user1);
        vault.deposit{value: 1 ether}();
        
        vm.prank(user1);
        vm.expectRevert(SecureVault.InsufficientBalance.selector);
        vault.withdraw(2 ether);
    }
    
    /// @notice Test that withdrawing without deposit reverts
    function test_RevertWhen_WithdrawWithoutDeposit() public {
        vm.prank(user1);
        vm.expectRevert(SecureVault.InsufficientBalance.selector);
        vault.withdraw(1 ether);
    }
    
    // ============ Ownership Tests ============
    
    /// @notice Test successful ownership transfer
    function test_TransferOwnershipSuccessfully() public {
        address newOwner = makeAddr("newOwner");
        
        // Expect the OwnershipTransferred event
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(owner, newOwner);
        
        vault.transferOwnership(newOwner);
        
        assertEq(vault.owner(), newOwner);
    }
    
    /// @notice Test that non-owner cannot transfer ownership
    function test_RevertWhen_NonOwnerTransfersOwnership() public {
        address newOwner = makeAddr("newOwner");
        
        vm.prank(user1);
        vm.expectRevert(SecureVault.NotOwner.selector);
        vault.transferOwnership(newOwner);
    }
    
    /// @notice Test that transferring to zero address reverts
    function test_RevertWhen_TransferOwnershipToZeroAddress() public {
        vm.expectRevert(SecureVault.ZeroAddress.selector);
        vault.transferOwnership(address(0));
    }
    
    // ============ View Functions Tests ============
    
    /// @notice Test getContractBalance function
    function test_GetContractBalance() public {
        vm.prank(user1);
        vault.deposit{value: 5 ether}();
        
        assertEq(vault.getContractBalance(), 5 ether);
    }
    
    /// @notice Test getUserBalance function
    function test_GetUserBalance() public {
        uint256 amount = 3 ether;
        
        vm.prank(user1);
        vault.deposit{value: amount}();
        
        assertEq(vault.getUserBalance(user1), amount);
        assertEq(vault.getUserBalance(user2), 0);
    }
    
    // ============ Invariant Tests ============
    
    /// @notice Test that totalDeposits always equals contract balance
    function test_Invariant_TotalDepositsEqualsContractBalance() public {
        // Multi-user activity
        vm.prank(user1);
        vault.deposit{value: 7 ether}();
        
        vm.prank(user2);
        vault.deposit{value: 3 ether}();
        
        vm.prank(user1);
        vault.withdraw(2 ether);
        
        // Verify invariant
        assertEq(vault.totalDeposits(), address(vault).balance, 
                 "totalDeposits must equal contract balance");
    }
    
    /// @notice Test invariant after complex scenario
    function test_Invariant_AfterComplexScenario() public {
        vm.prank(user1);
        vault.deposit{value: 10 ether}();
        
        vm.prank(user2);
        vault.deposit{value: 5 ether}();
        
        vm.prank(user1);
        vault.withdraw(3 ether);
        
        vm.prank(user2);
        vault.deposit{value: 2 ether}();
        
        vm.prank(user1);
        vault.withdraw(4 ether);
        
        // Verify invariant holds
        assertEq(vault.totalDeposits(), address(vault).balance);
        assertEq(vault.totalDeposits(), 
                 vault.getUserBalance(user1) + vault.getUserBalance(user2));
    }
    
    // ============ Fuzz Tests ============
    
    /// @notice Fuzz test for deposits with random amounts
    /// @param amount Random amount for deposit
    function testFuzz_Deposit(uint256 amount) public {
        // Limit amount to avoid overflow
        vm.assume(amount > 0 && amount <= 1000 ether);
        
        vm.deal(user1, amount);
        
        vm.prank(user1);
        vault.deposit{value: amount}();
        
        assertEq(vault.getUserBalance(user1), amount);
        assertEq(vault.totalDeposits(), amount);
        assertEq(address(vault).balance, amount);
    }
    
    /// @notice Fuzz test for withdrawals
    /// @param depositAmount Deposit amount
    /// @param withdrawAmount Withdrawal amount
    function testFuzz_Withdraw(uint256 depositAmount, uint256 withdrawAmount) public {
        vm.assume(depositAmount > 0 && depositAmount <= 1000 ether);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= depositAmount);
        
        vm.deal(user1, depositAmount);
        
        vm.startPrank(user1);
        vault.deposit{value: depositAmount}();
        vault.withdraw(withdrawAmount);
        vm.stopPrank();
        
        assertEq(vault.getUserBalance(user1), depositAmount - withdrawAmount);
        assertEq(vault.totalDeposits(), depositAmount - withdrawAmount);
    }
    
    /// @notice Fuzz test to verify invariant holds with random operations
    function testFuzz_InvariantHolds(uint96 amount1, uint96 amount2, uint96 withdrawAmount) public {
        vm.assume(amount1 > 0 && amount1 < 100 ether);
        vm.assume(amount2 > 0 && amount2 < 100 ether);
        vm.assume(withdrawAmount > 0 && withdrawAmount <= amount1);
        
        vm.deal(user1, amount1);
        vm.deal(user2, amount2);
        
        vm.prank(user1);
        vault.deposit{value: amount1}();
        
        vm.prank(user2);
        vault.deposit{value: amount2}();
        
        vm.prank(user1);
        vault.withdraw(withdrawAmount);
        
        // Invariant must hold
        assertEq(vault.totalDeposits(), address(vault).balance);
    }
    
    // ============ Integration Tests ============
    
    /// @notice Complex scenario test with multiple operations
    function test_ComplexScenario() public {
        // User1 makes a deposit
        vm.prank(user1);
        vault.deposit{value: 10 ether}();
        
        // User2 makes a deposit
        vm.prank(user2);
        vault.deposit{value: 5 ether}();
        
        // User1 withdraws part
        vm.prank(user1);
        vault.withdraw(3 ether);
        
        // User2 makes another deposit
        vm.prank(user2);
        vault.deposit{value: 2 ether}();
        
        // Verify final balances
        assertEq(vault.getUserBalance(user1), 7 ether);
        assertEq(vault.getUserBalance(user2), 7 ether);
        assertEq(vault.totalDeposits(), 14 ether);
        assertEq(vault.getContractBalance(), 14 ether);
    }
    
    /// @notice Test sequential withdrawals to zero
    function test_SequentialWithdrawalsToZero() public {
        uint256 depositAmount = 10 ether;
        
        vm.prank(user1);
        vault.deposit{value: depositAmount}();
        
        vm.startPrank(user1);
        vault.withdraw(4 ether);
        vault.withdraw(3 ether);
        vault.withdraw(3 ether);
        vm.stopPrank();
        
        assertEq(vault.getUserBalance(user1), 0);
        assertEq(vault.totalDeposits(), 0);
    }
}

/// @title Reverting Receiver Contract for Testing
/// @notice This contract is used to test failed ETH transfers
contract RevertingReceiver {
    SecureVault public vault;
    
    constructor(SecureVault _vault) {
        vault = _vault;
    }
    
    /// @notice Allows the contract to deposit into the vault
    function depositToVault() external payable {
        vault.deposit{value: msg.value}();
    }
    
    /// @notice Attempts to withdraw from the vault (will fail on receive)
    function attemptWithdraw(uint256 amount) external {
        vault.withdraw(amount);
    }
    
    /// @notice Revert on receiving ETH to simulate transfer failure
    receive() external payable {
        revert("Refusing ETH");
    }
}

/// @title Extended SecureVault Tests
/// @notice Additional tests for edge cases and security
contract SecureVaultExtendedTest is Test {
    SecureVault public vault;
    RevertingReceiver public revertingReceiver;
    address public owner;
    
    function setUp() public {
        owner = address(this);
        vault = new SecureVault();
        revertingReceiver = new RevertingReceiver(vault);
        
        vm.deal(address(revertingReceiver), 10 ether);
    }
    
    /// @notice Test that withdrawal fails when receiver rejects ETH
    function test_RevertWhen_ReceiverRejectsETH() public {
        // Deposit from the reverting receiver contract
        vm.prank(address(revertingReceiver));
        revertingReceiver.depositToVault{value: 1 ether}();
        
        // Attempt to withdraw should fail
        vm.prank(address(revertingReceiver));
        vm.expectRevert(SecureVault.TransferFailed.selector);
        revertingReceiver.attemptWithdraw(1 ether);
    }
}
