// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import "./Looper.sol";

import {Utils} from "../../utils/Utils.sol";
import "../../calls/CallHyvm.sol";

import "test/calls/limitTesting/LoopedCall_hyvm.sol";

contract LoopedCallTest is Test {
    address hyvm;
    Looper looper;
    address owner;
    CallHyvm callHyvm;
    bytes loopedCallByteCode;

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();
        loopedCallByteCode = type(LoopedCall).creationCode;
        looper = new Looper(hyvm, loopedCallByteCode);
    }

    function testLooper() public {
        callHyvm.callHyvm(hyvm, abi.encodePacked(loopedCallByteCode, abi.encode(address(looper)), uint256(0)));
    }
}
