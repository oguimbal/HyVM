// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

contract CallHyvm {

    function callHyvm(address hyvm, bytes calldata bytecode) public {
        (bool success, ) = hyvm.delegatecall(bytecode);
        require(success, 'Failed to call HyVM');
    }

    receive() external payable {}
}
