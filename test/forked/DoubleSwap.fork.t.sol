// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {DoubleSwap} from "./calls/doubleSwap/DoubleSwap.sol";
import {CallHyvm} from "./calls/CallHyvm.sol";

import {IERC20} from "../utils/interfaces/IERC20.sol";
import {Utils} from "../utils/Utils.sol";
import {DAI, USDC} from "./ConstantsEthereum.sol";

contract DoubleSwapTests is Test {
    address hyvm;
    address owner;
    CallHyvm callHyvm;

    address doubleSwapHuff;
    DoubleSwap doubleSwap;
    bytes doubleswapHyvmBytecode;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.config().with_evm_version("paris").deploy("HyVM");
        callHyvm = new CallHyvm();

        doubleSwapHuff = HuffDeployer.config().with_evm_version("paris").deploy("../test/forked/calls/doubleSwap/DoubleSwap");
        doubleSwap = new DoubleSwap();
        doubleswapHyvmBytecode = type(DoubleSwap).runtimeCode;
    }

    receive() external payable {}

    function testDoubleSwap_native_solidity() public {
        deal(USDC, address(doubleSwap), 100_000_000 * 10 ** 6);
        doubleSwap.doubleSwap();
    }

    function testDoubleSwap_hyvm_solidity() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10 ** 6);
        // replace "doubleSwap" selector and bypass calldata size check
        bytes memory finalBytecode = Utils.replaceSelectorBypassCalldataSizeCheck(doubleswapHyvmBytecode, hex"64c2c785");
        callHyvm.callHyvm(hyvm, finalBytecode);
        require(IERC20(DAI).balanceOf(address(callHyvm)) >= 9800000000000000);
    }

    function testDoubleSwap_native_huff() public {
        deal(USDC, address(this), 100_000_000 * 10 ** 6);
        (bool success,) = doubleSwapHuff.delegatecall(new bytes(0));
        assertEq(success, true);
        require(IERC20(DAI).balanceOf(address(this)) >= 9800000000000000);
    }

    function testDoubleSwap_hyvm_huff() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10 ** 6);
        callHyvm.callHyvm(hyvm, doubleSwapHuff.code);
        require(IERC20(DAI).balanceOf(address(callHyvm)) >= 9800000000000000);
    }
}
