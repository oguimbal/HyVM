// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

interface SimpleStore {
  function setValue(uint256) external;
  function getValue() external returns (uint256);
}

contract Deploy is Script {
  function run() public returns (address deployedAddress) {
        string memory bashCommand = 'cast abi-encode "f(bytes)" $(huffc ./src/NVM.huff --bytecode | head)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytes memory bytecode = abi.decode(vm.ffi(inputs), (bytes));

        vm.startBroadcast();
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(
            deployedAddress != address(0),
            "HuffDeployer could not deploy contract"
        );

        vm.stopBroadcast();
        // console.log("Deployed at ", deployedAddress);
        return deployedAddress;
  }
}
