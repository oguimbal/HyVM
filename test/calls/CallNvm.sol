// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

contract CallNvm {

    function callNvm(address nvm, bytes calldata bytecode) public {
        (bool success, ) = nvm.delegatecall(bytecode);
        require(success, 'Failed to call NVM');
    }

    receive() external payable {}
}
