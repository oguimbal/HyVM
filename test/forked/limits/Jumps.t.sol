// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {CallHyvm} from "../calls/CallHyvm.sol";

import {IERC20} from "../../utils/interfaces/IERC20.sol";
import {IUniswapV2Router01} from "../../utils/interfaces/IUniswapV2Router01.sol";

import {Jumps} from "../calls/limitTesting/Jumps_hyvm.sol";

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

        jumpsHyvmBytecode = type(Jumps).creationCode;
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