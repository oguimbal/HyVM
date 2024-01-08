// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {CallHyvm} from "../calls/CallHyvm.sol";

import {IERC20} from "../../utils/interfaces/IERC20.sol";
import {IUniswapV2Router01} from "../../utils/interfaces/IUniswapV2Router01.sol";

import {AbsurdDeclaration} from "../calls/limitTesting/MaximumStackSize_hyvm.sol";

contract LimitSwapsTest is Test {
    address hyvm;
    address owner;
    CallHyvm callHyvm;
    bytes maximumStackSizeHyvmBytecode;

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"), 18868834);
        owner = address(this);
        hyvm = HuffDeployer.config().with_evm_version("paris").deploy("HyVM");
        callHyvm = new CallHyvm();

        maximumStackSizeHyvmBytecode = type(AbsurdDeclaration).creationCode;
    }

    function testMaximumStackSizeHyvm1() public {
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(maximumStackSizeHyvmBytecode));
        // This call works
        callHyvm.callHyvm(hyvm, abi.encode(maximumStackSizeHyvmBytecode, maximumStackSizeHyvmBytecode));
        // This call works
        callHyvm.callHyvm(
            hyvm, abi.encode(maximumStackSizeHyvmBytecode, maximumStackSizeHyvmBytecode, maximumStackSizeHyvmBytecode)
        );
        // This call works
        callHyvm.callHyvm(
            hyvm,
            abi.encode(
                maximumStackSizeHyvmBytecode,
                maximumStackSizeHyvmBytecode,
                maximumStackSizeHyvmBytecode,
                maximumStackSizeHyvmBytecode
            )
        );
        // This call works, but one more and this file can't
        // be compiled => "Stack too deep."
        callHyvm.callHyvm(
            hyvm,
            abi.encode(
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
            )
        );
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
