// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "foundry-huff/HuffDeployer.sol";

/// @notice Deploy the HyVM using CREATE2
contract Deploy is Script {
    // The address is the same on all EVM chains.
    ICreateX public constant DEPLOYER = ICreateX(0xba5Ed099633D3B313e4D5F7bdc1305d3c28ba5Ed);

    function run() public returns (address deployedAddress) {
        string memory bashCommand = 'cast abi-encode "f(bytes)" $(huffc ./src/HyVM.huff --bytecode -e paris | head)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytes memory bytecode = abi.decode(vm.ffi(inputs), (bytes));
        // See createX documentation for more information on salt:
        // * address(0) allows for permissionless deployment
        // * hex"00" no cross-chain redeploy protection
        bytes32 salt = bytes32(abi.encodePacked(address(0), hex"00", bytes11(uint88(uint256(keccak256("HyVM_V1"))))));
        bytes32 guardedSalt = keccak256(abi.encode(salt));
        vm.startBroadcast();

        // Call CREATE2 Deployer
        deployedAddress = DEPLOYER.deployCreate2(salt, bytecode);
        address computedDeployedAddress = DEPLOYER.computeCreate2Address(guardedSalt, keccak256(bytecode));

        // Check if contract deployed at expected address
        require(deployedAddress == computedDeployedAddress);
        require(deployedAddress.code.length > 0, "HyVM not deployed");

        vm.stopBroadcast();

        return deployedAddress;
    }
}

/**
 * @title CreateX Factory Interface Definition
 * @author pcaversaccio (https://web.archive.org/web/20230921103111/https://pcaversaccio.com/)
 * @custom:coauthor Matt Solomon (https://web.archive.org/web/20230921103335/https://mattsolomon.dev/)
 */
interface ICreateX {
    function deployCreate2(bytes32 salt, bytes memory initCode) external payable returns (address newContract);
    function computeCreate2Address(bytes32 salt, bytes32 initCodeHash)
        external
        view
        returns (address computedAddress);
}