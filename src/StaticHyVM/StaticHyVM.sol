// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

/// @title StaticHyVM
/// @notice Static delegate call to HyVM contract
/// @dev Only callable from this contract
///      Inspired from https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/readonly-delegatecall
contract StaticHyVM {
    /// @dev HyVM contract address
    address public immutable hyvm;

    /// @dev When address provided is not a contract
    error AddressNotContract(address addr);

    /// @dev When trying to call doDelegateCall function externally
    error OnlySelf();

    constructor(address _hyvm) {
        if (_hyvm.code.length == 0) {
            revert AddressNotContract(_hyvm);
        }
        hyvm = _hyvm;
    }

    /// @notice Delegate call to HyVM contract
    /// @dev Only callable from this contract
    ///      Bubble error from delegate call
    /// @param payload Payload to be executed
    /// @return data Return data from delegate call
    function doDelegateCall(bytes calldata payload) public returns (bytes memory) {
        if (msg.sender != address(this)) revert OnlySelf();

        (bool success, bytes memory data) = hyvm.delegatecall(payload);
        if (!success) _bubbleError(data, "StaticHyVM: delegatecall failed");
        return data;
    }

    /// @notice Static delegate call to HyVM contract
    /// @dev Bubble error from staticcall
    /// @param payload Payload to be executed
    /// @return data Return data from static call
    function staticExec(bytes calldata payload) external view returns (bytes memory) {
        (bool success, bytes memory data) = address(this).staticcall(abi.encodeCall(this.doDelegateCall, payload));
        if (!success) _bubbleError(data, "StaticHyVM: staticcall failed");
        // decode data to emulate delegatecall return data format
        return abi.decode(data, (bytes));
    }

    /// @dev Bubble error from data or revert with provided error message
    /// @param data Data to bubble error from
    /// @param errorMessage Error message to revert with if data is empty
    function _bubbleError(bytes memory data, string memory errorMessage) private pure {
        if (data.length > 0) {
            assembly {
                revert(add(data, 0x20), mload(data))
            }
        }
        revert(errorMessage);
    }
}
