// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BasedFusaka} from "../src/BasedFusaka.sol";

contract BasedFusakaTest is Test {
    BasedFusaka public token;
    address public owner;
    address public user1;
    address public user2;
    uint256 public initialSupply = 1000000; // 1M tokens

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        token = new BasedFusaka(initialSupply);
    }

    // Constructor Tests
    function test_Constructor() public view {
        assertEq(token.name(), "BasedFusaka");
        assertEq(token.symbol(), "BFK");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), initialSupply * 10**18);
        assertEq(token.balanceOf(owner), initialSupply * 10**18);
        assertEq(token.owner(), owner);
    }

    function test_ConstructorZeroSupply() public {
        vm.expectRevert(BasedFusaka.BasedFusaka__ZeroAmount.selector);
        new BasedFusaka(0);
    }

    // ERC-20 Standard Tests
    function test_Transfer() public {
        uint256 amount = 1000 * 10**18;
        assert(token.transfer(user1, amount));
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), (initialSupply * 10**18) - amount);
    }

    function test_TransferZeroAddress() public {
        vm.expectRevert();
        assert(!token.transfer(address(0), 1000 * 10**18));
    }

    function test_TransferInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 1000 * 10**18);
    }

    function test_ApproveAndTransferFrom() public {
        uint256 amount = 1000 * 10**18;
        token.approve(user1, amount);
        assertEq(token.allowance(owner, user1), amount);

        vm.prank(user1);
        assert(token.transferFrom(owner, user2, amount));
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.allowance(owner, user1), 0);
    }

    // Ownable Tests
    function test_Owner() public view {
        assertEq(token.owner(), owner);
    }

    function test_TransferOwnership() public {
        token.transferOwnership(user1);
        assertEq(token.owner(), user1);
    }

    function test_OnlyOwnerCanTransferOwnership() public {
        vm.prank(user1);
        vm.expectRevert();
        token.transferOwnership(user2);
    }

    // Mint Tests
    function test_Mint() public {
        uint256 mintAmount = 500000; // 500K tokens
        token.mint(user1, mintAmount);
        assertEq(token.balanceOf(user1), mintAmount * 10**18);
        assertEq(token.totalSupply(), (initialSupply + mintAmount) * 10**18);
    }

    function test_MintZeroAddress() public {
        vm.expectRevert(BasedFusaka.BasedFusaka__ZeroAddress.selector);
        token.mint(address(0), 1000);
    }

    function test_MintZeroAmount() public {
        vm.expectRevert(BasedFusaka.BasedFusaka__ZeroAmount.selector);
        token.mint(user1, 0);
    }

    function test_OnlyOwnerCanMint() public {
        vm.prank(user1);
        vm.expectRevert();
        token.mint(user2, 1000);
    }

    // Burn Tests
    function test_Burn() public {
        uint256 burnAmount = 1000;
        token.burn(burnAmount);
        assertEq(token.balanceOf(owner), (initialSupply - burnAmount) * 10**18);
        assertEq(token.totalSupply(), (initialSupply - burnAmount) * 10**18);
    }

    function test_BurnZeroAmount() public {
        vm.expectRevert(BasedFusaka.BasedFusaka__ZeroAmount.selector);
        token.burn(0);
    }

    function test_BurnInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert(BasedFusaka.BasedFusaka__InsufficientBalance.selector);
        token.burn(1000);
    }

    function test_BurnByUser() public {
        token.transfer(user1, 1000 * 10**18);
        vm.prank(user1);
        token.burn(500);
        assertEq(token.balanceOf(user1), 500 * 10**18);
    }

    // Pause Tests
    function test_Pause() public {
        token.pause();
        assertTrue(token.paused());
    }

    function test_Unpause() public {
        token.pause();
        token.unpause();
        assertFalse(token.paused());
    }

    function test_OnlyOwnerCanPause() public {
        vm.prank(user1);
        vm.expectRevert();
        token.pause();
    }

    function test_OnlyOwnerCanUnpause() public {
        token.pause();
        vm.prank(user1);
        vm.expectRevert();
        token.unpause();
    }

    function test_TransferWhenPaused() public {
        token.pause();
        vm.expectRevert();
        assert(!token.transfer(user1, 1000 * 10**18));
    }

    function test_ApproveWhenPaused() public {
        token.pause();
        vm.expectRevert();
        token.approve(user1, 1000 * 10**18);
    }

    function test_TransferFromWhenPaused() public {
        token.approve(user1, 1000 * 10**18);
        token.pause();
        vm.prank(user1);
        vm.expectRevert();
        assert(!token.transferFrom(owner, user2, 1000 * 10**18));
    }

    // Events Tests
    function test_MintEvent() public {
        uint256 mintAmount = 1000;
        vm.expectEmit(true, false, false, true);
        emit BasedFusaka.TokensMinted(user1, mintAmount * 10**18);
        token.mint(user1, mintAmount);
    }

    function test_BurnEvent() public {
        uint256 burnAmount = 1000;
        vm.expectEmit(true, false, false, true);
        emit BasedFusaka.TokensBurned(owner, burnAmount * 10**18);
        token.burn(burnAmount);
    }
}