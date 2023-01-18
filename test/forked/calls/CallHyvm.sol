// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

contract CallHyvm {
    function callHyvm(address hyvm, bytes calldata bytecode) public returns (bytes memory) {
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        require(success, "Failed to call HyVM");
        return data;
    }

    receive() external payable {}
}
