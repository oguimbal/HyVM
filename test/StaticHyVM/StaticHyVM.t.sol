// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import {Utils} from "../utils/Utils.sol";

import "src/StaticHyVM/StaticHyVM.sol";

contract TestStaticHyVM is Test {
    address public hyvm;
    StaticHyVM public staticHyvm;
    Dummy public dummy;
    bytes public bytecode;

    function setUp() public {
        hyvm = HuffDeployer.deploy("HyVM");
        vm.label(hyvm, "HyVM");

        staticHyvm = new StaticHyVM(hyvm);
        vm.label(address(staticHyvm), "StaticHyVM");

        dummy = new Dummy();
        vm.label(address(dummy), "Dummy");

        bytecode = type(CallDummy).runtimeCode;
        bytecode = Utils.replace(bytecode, 0x1231231233123123123312312312331231231233, address(dummy));
    }

    function testCannotDeployIfNotContract() public {
        address notContract = makeAddr("notContract");
        vm.expectRevert(abi.encodeWithSelector(StaticHyVM.AddressNotContract.selector, notContract));
        new StaticHyVM(notContract);
    }

    function testContructor() public {
        assertEq(staticHyvm.hyvm(), hyvm);
    }

    function testCannotCallDoDelegateCallExternally() public {
        vm.expectRevert(abi.encodeWithSelector(StaticHyVM.OnlySelf.selector));
        staticHyvm.doDelegateCall("");
    }

    function testCannotStaticExecWriteFunction() public {
        bytecode = Utils.replaceSelectorBypassCalldataSizeCheck(bytecode, hex"c350518d");

        vm.expectRevert(bytes("StaticHyVM: delegatecall failed"));
        staticHyvm.staticExec(bytecode);
    }

    function testStaticExecFailWithoutBubblingError() public {
        bytecode = Utils.replaceSelectorBypassCalldataSizeCheck(bytecode, hex"076e644b");

        vm.expectRevert(bytes("StaticHyVM: delegatecall failed"));
        staticHyvm.staticExec(bytecode);
    }

    function testStaticExecFailWithBubblingError() public {
        bytecode = Utils.replaceSelectorBypassCalldataSizeCheck(bytecode, hex"0d0d2f38");

        vm.expectRevert(bytes("Dummy: failWithMessage"));
        staticHyvm.staticExec(bytecode);
    }

    function testStaticExec() public {
        bytecode = Utils.replaceSelectorBypassCalldataSizeCheck(bytecode, hex"6db76487");

        bytes memory data = staticHyvm.staticExec(bytecode);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, uint256(1));
    }

    function testStaticExecReadStorage() public {
        bytecode = Utils.replaceSelectorBypassCalldataSizeCheck(bytecode, hex"0d21a47d");
        bytes memory data = staticHyvm.staticExec(bytecode);
        bytes32 result = abi.decode(data, (bytes32));
        assertEq(result, keccak256("DUMMY_STORAGE"));
    }
}

contract Dummy {
    bytes32 public dummyStorage = keccak256("DUMMY_STORAGE");

    function fail() external {
        revert();
    }

    function failWithMessage() external {
        revert("Dummy: failWithMessage");
    }

    function getUint256() external pure returns (uint256) {
        return uint256(1);
    }

    function writeStorage() external {
        dummyStorage = keccak256("CHANGE_DUMMY_STORAGE");
    }
}

contract CallDummy {
    function callFail() public {
        Dummy(0x1231231233123123123312312312331231231233).fail();
    }

    function callFailWithMessage() public {
        Dummy(0x1231231233123123123312312312331231231233).failWithMessage();
    }

    function callGetUint256() public returns (uint256) {
        return Dummy(0x1231231233123123123312312312331231231233).getUint256();
    }

    function callWriteStorage() public {
        return Dummy(0x1231231233123123123312312312331231231233).writeStorage();
    }

    function callDummyStorage() public returns (bytes32) {
        return Dummy(0x1231231233123123123312312312331231231233).dummyStorage();
    }
}