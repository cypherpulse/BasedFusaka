// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @title BasedFusaka (BFK) - Base Native ERC-20 Token
/// @author cypherpulse.base.eth
/// @notice Production-grade ERC-20 token built with OpenZeppelin for Base mainnet
/// @dev Deploy-ready for Base mainnet (8453). Implements ERC20, Ownable, and Pausable.
///      Constructor mints initial supply to deployer. Owner can mint, burn, pause, unpause.
///      Burn function allows any holder to burn their tokens.
///      Pausable for emergency stops on transfers and approvals.

contract BasedFusaka is ERC20, Ownable, Pausable {
    /// @dev Custom errors for gas-efficient reverts
    error BasedFusaka__ZeroAddress();
    error BasedFusaka__ZeroAmount();
    error BasedFusaka__InsufficientBalance();

    /// @dev Emitted when tokens are minted
    event TokensMinted(address indexed to, uint256 amount);
    /// @dev Emitted when tokens are burned
    event TokensBurned(address indexed from, uint256 amount);

    /// @notice Constructor mints initial supply to deployer
    /// @param initialSupply The initial token supply (without decimals)
    constructor(uint256 initialSupply)
        ERC20("BasedFusaka", "BFK")
        Ownable(msg.sender)
    {
        if (initialSupply == 0) revert BasedFusaka__ZeroAmount();
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    /// @notice Mint new tokens to specified address (only owner)
    /// @param to The address to mint tokens to
    /// @param amount The amount of tokens to mint (without decimals)
    function mint(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert BasedFusaka__ZeroAddress();
        if (amount == 0) revert BasedFusaka__ZeroAmount();
        _mint(to, amount * 10**decimals());
        emit TokensMinted(to, amount * 10**decimals());
    }

    /// @notice Burn tokens from caller's balance
    /// @param amount The amount of tokens to burn (without decimals)
    function burn(uint256 amount) external {
        if (amount == 0) revert BasedFusaka__ZeroAmount();
        uint256 burnAmount = amount * 10**decimals();
        if (balanceOf(msg.sender) < burnAmount) revert BasedFusaka__InsufficientBalance();
        _burn(msg.sender, burnAmount);
        emit TokensBurned(msg.sender, burnAmount);
    }

    /// @notice Pause all token transfers and approvals (only owner)
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpause all token transfers and approvals (only owner)
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @dev Override _update to include pause check
    /// @param from The sender address
    /// @param to The receiver address
    /// @param value The amount to transfer
    function _update(address from, address to, uint256 value) internal override whenNotPaused {
        super._update(from, to, value);
    }
}