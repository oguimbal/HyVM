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
    bytes jumpsHyvmBytecode;

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(
            vm.rpcUrl('eth')
        );
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();

        jumpsHyvmBytecode = getMaximumStackSizeHyvmBytecodeBytecode();
    }

    function getMaximumStackSizeHyvmBytecodeBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/limitTesting/Jumps_hyvm.sol | head -12 | tail -1)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    function testJumpsHyvmBytecode0() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(0)
        ));
    }

    function testJumpsHyvmBytecode1() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(1)
        ));
    }

    function testJumpsHyvmBytecode2() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(2)
        ));
    }

    function testJumpsHyvmBytecode3() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(3)
        ));
    }

    function testJumpsHyvmBytecode4() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(4)
        ));
    }

    function testJumpsHyvmBytecode5() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(5)
        ));
    }

    function testJumpsHyvmBytecode6() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(6)
        ));
    }

    function testJumpsHyvmBytecode7() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(7)
        ));
    }

    function testJumpsHyvmBytecode8() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(8)
        ));
    }

    function testJumpsHyvmBytecode9() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(
            jumpsHyvmBytecode, uint256(9)
        ));
    }
}