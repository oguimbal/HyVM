// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../calls/CallHyvm.sol";

import "../calls/IERC20.sol";
import "../calls/IUniswapV2Router01.sol";

contract LimitSwapsTest is Test {
    address hyvm;
    address owner;
    CallHyvm callHyvm;
    bytes maximumStackSizeHyvmBytecode;

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(
            vm.rpcUrl('eth')
        );
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();

        maximumStackSizeHyvmBytecode = getMaximumStackSizeHyvmBytecodeBytecode();
    }

    function getMaximumStackSizeHyvmBytecodeBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/limitTesting/MaximumStackSize_hyvm.sol | head -12 | tail -1)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    function testMaximumStackSizeHyvm1() public {
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(
            maximumStackSizeHyvmBytecode
        ));
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode
        ));
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode
        ));
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode
        ));
        // This call works, but one more and this file can't
        // be compiled => "Stack too deep."
        callHyvm.callHyvm(hyvm, abi.encode(
            maximumStackSizeHyvmBytecode, 
            maximumStackSizeHyvmBytecode, 
            maximumStackSizeHyvmBytecode, 
            maximumStackSizeHyvmBytecode, 
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode,
            maximumStackSizeHyvmBytecode
        ));
    }

    // This test can't be compiled because of the stack size
    // function testMaximumStackSizeHyvm2() public {
    //     callHyvm.callHyvm(hyvm, abi.encode(
    //         maximumStackSizeHyvmBytecode, 
    //         maximumStackSizeHyvmBytecode, 
    //         maximumStackSizeHyvmBytecode, 
    //         maximumStackSizeHyvmBytecode, 
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode,
    //         maximumStackSizeHyvmBytecode
    //     ));
    // }
}