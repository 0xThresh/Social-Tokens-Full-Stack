// SPDX-License-Identifier: CC0

pragma solidity ^0.8.8;

/// @title ERC-4974 Experience (EXP) Token Standard
/// @dev See https://eips.ethereum.org/EIPS/EIP-4974
///  Note: the ERC-165 identifier for this interface is 0x696e7752.
///  Must initialize contracts with an `operator` address that is not `address(0)`.
///  Must initialize contracts assigning participation as `true` for both `operator` and `address(0)`.
interface IERC4974 /* is ERC165 */ {

    /// @dev Emits when operator changes.
    ///  MUST emit when `operator` changes by any mechanism.
    ///  MUST ONLY emit by `setOperator`.
    event Appointment(address indexed _operator);

    /// @dev Emits when operator transfers EXP. 
    ///  MUST emit when EXP is transferred by any mechanism.
    ///  MUST ONLY emit by `transfer`.
    event Transfer(address indexed _to, uint256 _amount);

    /// @dev Emits when operator burns EXP. 
    ///  MUST emit when EXP is burned by any mechanism.
    ///  MUST ONLY emit by `burn`.
    event Burn(address indexed _from, uint256 _amount);

    /// @notice Appoint operator authority.
    /// @dev MUST throw unless `msg.sender` is `operator`.
    ///  MUST throw if `operator` address is either already current `operator`
    ///  or is the zero address.
    ///  MUST emit an `Appointment` event.
    /// @param _operator New operator of the smart contract.
    function setOperator(address _operator) external;

    /// @notice Transfer EXP from one address to a participating address.
    /// @dev MUST throw unless `msg.sender` is `operator`.
    ///  MUST throw unless `to` address is participating.
    ///  MUST throw if `to` and `from` are the same address.
    ///  MUST emit a Transfer event with each successful call.
    ///  SHOULD throw if `amount` is zero.
    ///  MAY allow minting from zero address, burning to the zero address, 
    ///  transferring between accounts, and transferring between contracts.
    ///  MAY limit interaction with non-participating `from` addresses.
    /// @param _to Address to which EXP tokens at `from` address will transfer.
    /// @param _amount Total EXP tokens to reallocate.
    function transfer(address _to, uint256 _amount) external;

    /// @notice Burn EXP from one address.
    /// @dev MUST throw unless `msg.sender` is `operator`.
    ///  MUST throw unless `to` address is participating.
    ///  MUST throw if `to` and `from` are the same address.
    ///  MUST emit a Transfer event with each successful call.
    ///  SHOULD throw if `amount` is zero.
    ///  MAY allow minting from zero address, burning to the zero address, 
    ///  transferring between accounts, and transferring between contracts.
    ///  MAY limit interaction with non-participating `from` addresses.
    /// @param _from Address from which to transfer EXP tokens.
    /// @param _amount Total EXP tokens to reallocate.
    function burn(address _from, uint256 _amount) external;

    /// @notice Return total EXP managed by this contract.
    /// @dev MUST sum EXP tokens of all `participant` addresses, 
    ///  regardless of participation status, excluding only the zero address.
    function totalSupply() external view returns (uint256);

    /// @notice Return total EXP allocated to a participant.
    /// @dev MUST register each time `Transfer` emits.
    ///  SHOULD throw for queries about the zero address.
    /// @param _participant An address for whom to query EXP total.
    /// @return uint256 The number of EXP allocated to `participant`, possibly zero.
    function balanceOf(address _participant) external view returns (uint256);
}

interface IERC165 {
    /// @notice Query if a contract implements an interface.
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @param interfaceID The interface identifier, as specified in ERC-165.
    /// @return bool `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise.
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}