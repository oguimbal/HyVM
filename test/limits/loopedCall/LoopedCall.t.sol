// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

import "./Looper.sol";

import "../../Utils.sol";
import "../../calls/CallHyvm.sol";

contract LoopedCall is Test {
    address hyvm;
    Looper looper;
    address owner;
    CallHyvm callHyvm;
    bytes loopedCallByteCode;

    //  =====   Set up  =====
    function setUp() public {

        vm.createSelectFork(
            vm.rpcUrl('eth')
        );
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();

        loopedCallByteCode = getLoopedCallBytecode();
        
        looper = new Looper(hyvm, loopedCallByteCode);
    }

    function getLoopedCallBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/limitTesting/LoopedCall_hyvm.sol | head -8 | tail -1)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    function testLooper() public {

        callHyvm.callHyvm(
            hyvm,
            abi.encodePacked(loopedCallByteCode, abi.encode(address(looper)), uint256(0))
        );
    }
}