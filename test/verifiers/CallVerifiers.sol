// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IHyVMCallVerifier.sol";
import {Utils} from "../utils/Utils.sol";
import "forge-std/console.sol";

contract VerifyAllCalls is IHyVMCallVerifier {
    function verifyCall(
        uint8 opcode,
        address callContract,
        uint256 valueSent,
        bytes memory callDataSlice,
        bool truncated
    ) public view returns (bool) {
        console.log("Will let this call pass:");
        console.log(opcode);
        console.log(callContract);
        console.log(valueSent);
        console.log(Utils.iToHex(callDataSlice));
        console.log(truncated);
        return true;
    }
}

contract VerifyOnlyCallsTo is IHyVMCallVerifier {
    address _onlyContract;

    constructor(address onlyContract) {
        _onlyContract = onlyContract;
    }

    function verifyCall(
        uint8 opcode,
        address callContract,
        uint256 valueSent,
        bytes memory callDataSlice,
        bool truncated
    ) public view returns (bool) {
        console.log("Verifying call...");
        console.log(opcode);
        console.log(callContract);
        console.log(valueSent);
        console.log(Utils.iToHex(callDataSlice));
        console.log(truncated);
        return _onlyContract == callContract;
    }
}

contract OnlyAllowExchengesWith is IHyVMCallVerifier {
    address _user;

    constructor(address user) {
        _user = user;
    }

    function verifyCall(
        uint8 opcode,
        address callContract,
        uint256 valueSent,
        bytes memory callDataSlice,
        bool truncated
    ) public view returns (bool) {
        bytes memory balanceOfSig = hex"70a08231";

        // check that this call starts with the balanceOf() or transfer() selector
        (bool success, uint256 index) = Utils.indexOf(callDataSlice, balanceOfSig, 0);
        if (!success || index != 0) {
            bytes memory transferSig = hex"a9059cbb";
            (success, index) = Utils.indexOf(callDataSlice, transferSig, 0);
            if (!success || index != 0) {
                console.log("Neither balanceOf() nor transfer() selectors found in calldata: ");
                console.log(Utils.iToHex(callDataSlice));
                return false;
            }
        }

        // then, check that it has the right length (4 bytes for the selector + one address)
        if (callDataSlice.length != (4 + 0x20)) {
            return false;
        }

        // find index of the given address
        (success, index) = Utils.indexOf(callDataSlice, abi.encodePacked(_user), 4);
        if (!success || index != 4) {
            console.log("Given address not found in calldata: ");
            console.log(Utils.iToHex(callDataSlice));
            return false;
        }
        return true;
    }
}
