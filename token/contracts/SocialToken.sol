// SPDX-License-Identifier: CC0

pragma solidity ^0.8.8; // 0.8.8 removes the requirement to add "override" to functions implementing an interface

import "../interfaces/IERC4974.sol";

/// @title Example SocialToken System
contract SocialToken is IERC4974 {

    address operator;
    address constant ZERO_ADDRESS = address(0); 
    uint256 totalTokens;
    mapping(address => uint256) public wallet_balance;

    constructor(uint256 _initialSupply) {
        operator = msg.sender;
        totalTokens = _initialSupply;
   }

    function setOperator(address _operator) external {
        ///  @dev EIP-4974 designates that the function: 
        ///  MUST throw unless `msg.sender` is `operator`.
        require(operator == msg.sender, "Only the current Operator can call setOperator.");
        
        ///  @dev MUST throw if `operator` address is either already current `operator`
        ///  or is the zero address.
        require(_operator != operator, "Address is already the current operator.");
        require(_operator != ZERO_ADDRESS, "Operator cannot be the zero address.");

        operator = _operator;

        emit Appointment(operator);
    }

    function getOperator() view external returns(address) {
        return operator;
    }

    // This function is only transferring from the contract despite the addition of the _to param
    // What needs to change to ensure user-to-user transfers can occur? 
    function transfer(address _to, uint256 _amount) external {
        /// @notice Transfer EXP from one address to a participating address.
        /// @param _to Address to which EXP tokens at `from` address will transfer.
        /// @param _amount Total EXP tokens to reallocate.
        /// @dev MUST throw unless `msg.sender` is `operator`.
        require(msg.sender == operator, "Only the operator can transfer tokens.");

        ///  SHOULD throw if `amount` is zero.
        require(_amount > 0, "Must transfer a non-zero amount.");

        ///  MUST throw if `to` and `from` are the same address.
        //require(_from != _to, "Cannot transfer to self.");

        // Check that tokens being transferred from _from are not greater than the number of tokens present in the address
        //require(wallet_balance[_from] > _amount, "Transfering address has less tokens than what transaction is attempting to transfer.");

        ///  MAY allow minting from zero address, burning to the zero address, 
        ///  transferring between accounts, and transferring between contracts.
        wallet_balance[_to] += _amount;
        // The offending line is below - we're only changing the value of totalTokens in the contract, not changing the value of tokens in _from 
        totalTokens -= _amount;

        ///  MUST emit a Transfer event with each successful call.
        emit Transfer(_to, _amount);
    }

    function totalSupply() external view returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _wallet) external view returns (uint256) {
        return wallet_balance[_wallet];
    }

    function burn(address _from, uint256 _amount) external {
        /// @notice Burn EXP.
        /// @param _from Address from which to burn EXP tokens.
        /// @param _amount Total EXP tokens to burn.
        /// @dev MUST throw unless `msg.sender` is `operator`.
        require(msg.sender == operator, "Only the operator can burn tokens.");

        ///  SHOULD throw if `amount` is zero.
        require(_amount > 0, "Must burn a non-zero amount.");

        /// Check that tokens being transferred from _from are not greater than the number of tokens present in the address
        require(wallet_balance[_from] >= _amount, "Targeted address has less tokens than what transaction is attempting to burn.");

        /// Burn tokens 
        wallet_balance[_from] -= _amount;

        ///  MUST emit a Transfer event with each successful call.
        emit Burn(_from, _amount);
    }
}



