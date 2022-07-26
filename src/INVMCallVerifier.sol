// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev A call verifier for NVM
 */
interface INVMCallVerifier {
    function verifyCall(
        uint8 opcode,
        address callContract,
        uint256 valueSent,
        bytes memory callDataSlice,
        bool truncated
    ) external returns (bool);
}
