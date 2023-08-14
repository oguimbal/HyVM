// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {Utils} from "../utils/Utils.sol";

contract OpcodesTest is Test {

    address public hyvm;

    function setUp() public {
        hyvm = HuffDeployer.config().with_evm_version("paris").deploy("HyVM");
        vm.label(hyvm, "HyVM");
    }

    // =============== UTILITIES =================

    function logStr(string memory str) public view {
        console.log(Utils.iToHex(abi.encodePacked(str), 32));
        console.log(Utils.iToHex(abi.encodePacked(bytes(str).length)));
    }

    // =================== TESTS ==============

    function testPushReturnMstore() public {
        // bytecode generated using: easm test/opcodes/push
        // ... which is 3+4
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7fff0100000000000000000000000000000000000000000000000000000000000060005260026000f3");
        assertEq(success, true);
        assertEq(data, hex"ff01");
    }

    function testAdd() public {
        // bytecode generated using: easm test/opcodes/add
        // ... which is 3+4
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360040160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 7);
    }

    function testMul() public {
        // bytecode generated using: easm test/opcodes/mul
        // ... which is 3*4
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360040260005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 12);
    }

    function testSub() public {
        // bytecode generated using: easm test/opcodes/sub
        // ... which is 7-3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360070360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }

    function testDiv() public {
        // bytecode generated using: easm test/opcodes/div
        // ... which is 15/3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6003600f0460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 5);
    }

    function testSDiv() public {
        // bytecode generated using: easm test/opcodes/sdiv
        // ... which is 16//3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360100560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 5);
    }

    function testMod() public {
        // bytecode generated using: easm test/opcodes/mod
        // ... which is 16%3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360100660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSMod() public {
        // bytecode generated using: easm test/opcodes/smod
        // ... which is 16%%3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600360100760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testAddmod() public {
        // bytecode generated using: easm test/opcodes/addmod
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6008600a600a0860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }

    function testMulmod() public {
        // bytecode generated using: easm test/opcodes/mulmod
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6008600a600a0960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }

    function testExp() public {
        // bytecode generated using: easm test/opcodes/exp
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6002600a0a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x64);
    }

    function testSignExtend() public {
        // bytecode generated using: easm test/opcodes/signextend
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff60000b60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testLt1() public {
        // bytecode generated using: easm test/opcodes/lt-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060091060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testLt2() public {
        // bytecode generated using: easm test/opcodes/lt-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060101060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testGt1() public {
        // bytecode generated using: easm test/opcodes/gt-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600960101160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testGt2() public {
        // bytecode generated using: easm test/opcodes/gt-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060101060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testSlt1() public {
        // bytecode generated using: easm test/opcodes/slt-1
        (bool success, bytes memory data) = hyvm.delegatecall(
            hex"60097fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1260005260ff6000f3"
        );
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSlt2() public {
        // bytecode generated using: easm test/opcodes/slt-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060101260005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testSgt1() public {
        // bytecode generated using: easm test/opcodes/sgt-1
        (bool success, bytes memory data) = hyvm.delegatecall(
            hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60091360005260ff6000f3"
        );
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSgt2() public {
        // bytecode generated using: easm test/opcodes/sgt-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060101360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testEq1() public {
        // bytecode generated using: easm test/opcodes/eq-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"601060101460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testEq2() public {
        // bytecode generated using: easm test/opcodes/eq-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600560101460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testIsZero1() public {
        // bytecode generated using: easm test/opcodes/iszero-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60101560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testIsZero2() public {
        // bytecode generated using: easm test/opcodes/iszero-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60001560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testAnd1() public {
        // bytecode generated using: easm test/opcodes/and-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600f600f1660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x0f);
    }

    function testAnd2() public {
        // bytecode generated using: easm test/opcodes/and-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600060ff1660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testOr1() public {
        // bytecode generated using: easm test/opcodes/or-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60f0600f1760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testOr2() public {
        // bytecode generated using: easm test/opcodes/or-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff60ff1760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testXor1() public {
        // bytecode generated using: easm test/opcodes/xor-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600f60f01860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testXor2() public {
        // bytecode generated using: easm test/opcodes/xor-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff60ff1860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x00);
    }

    function testNot() public {
        // bytecode generated using: easm test/opcodes/not
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60001960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testByte1() public {
        // bytecode generated using: easm test/opcodes/byte-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff601f1a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testByte2() public {
        // bytecode generated using: easm test/opcodes/byte-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff601e1a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testShl() public {
        // bytecode generated using: easm test/opcodes/shl
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600160011b60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 2);
    }

    function testShr() public {
        // bytecode generated using: easm test/opcodes/shr
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600260011c60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSar() public {
        // bytecode generated using: easm test/opcodes/sar
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600260011d60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSha3() public {
        // bytecode generated using: easm test/opcodes/sha3
        (bool success, bytes memory data) = hyvm.delegatecall(
            hex"7fffffffff00000000000000000000000000000000000000000000000000000000600052600460002060005260ff6000f3"
        );
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x29045a592007d0c246ef02c2223570da9522d0cf0f73282c79a1bc8f0bb2c238);
    }

    function testAddress_delegatecall() public {
        // bytecode generated using: easm test/opcodes/address
        (bool success, bytes memory data) = hyvm.delegatecall(hex"3060005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, address(this));
    }

    function testBalance() public {
        // bytecode generated using: easm test/opcodes/balance
        (bool success, bytes memory data) = hyvm.delegatecall(hex"303160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function testOrigin_delegatecall() public {
        // bytecode generated using: easm test/opcodes/origin
        (bool success, bytes memory data) = hyvm.delegatecall(hex"3260005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, DEFAULT_SENDER);
    }

    function testCaller_delegatecall() public {
        // bytecode generated using: easm test/opcodes/caller
        (bool success, bytes memory data) = hyvm.delegatecall(hex"3360005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, DEFAULT_SENDER);
    }

    function testCallvalue() public {
        // bytecode generated using: easm test/opcodes/callvalue
        (bool success, bytes memory data) = hyvm.delegatecall(hex"3460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testPc1() public {
        // bytecode generated using: easm test/opcodes/pc-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"5860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testPc2() public {
        // bytecode generated using: easm test/opcodes/pc-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"5b5860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testPc3() public {
        // bytecode generated using: easm test/opcodes/pc-3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"58585b5b5b58010160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 6);
    }

    function testMsize1() public {
        // bytecode generated using: easm test/opcodes/msize-1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"5960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testMsize2() public {
        // bytecode generated using: easm test/opcodes/msize-2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600051505960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x20);
    }

    function testGas() public {
        // bytecode generated using: easm test/opcodes/gas
        (bool success, bytes memory data) = hyvm.delegatecall(hex"5a5a900360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        // result will be 67 as there are instructions to read opcodes from bytecode
        // between the 2 gas instructions
        // see CONTINUE() macro:
        // opcodes below equals to 65 in gas hence gas opocode return the correct value
        // 3 push1 00
        // 3 mload
        // 3 dup1
        // 3 calldataload
        // 3 push1 f8
        // 3 shr
        // 3 swap1
        // 3 push1 01
        // 3 add
        // 3 push1 00
        // 3 mstore
        // 3 push1 02
        // 5 mul
        // 3 push1 20
        // 3 add
        // 3 mload
        // 3 push1 f0
        // 3 shr
        // 8 jump
        // 1 jumpdest
        // 2 gas
        assertEq(result, 0x43);
    }

    function testPush0() public {
        // bytecode generated using: easm test/opcodes/push0 but push0 is not supported hence added by hand
        (bool success, bytes memory data) = hyvm.delegatecall(hex"5f5f5260205ff3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, uint256(0));
    }

    function testPush1() public {
        // bytecode generated using: easm test/opcodes/push1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60ff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testPush2() public {
        // bytecode generated using: easm test/opcodes/push2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"61ffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffff);
    }

    function testPush3() public {
        // bytecode generated using: easm test/opcodes/push3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"62ffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffff);
    }

    function testPush4() public {
        // bytecode generated using: easm test/opcodes/push4
        (bool success, bytes memory data) = hyvm.delegatecall(hex"63ffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffff);
    }

    function testPush5() public {
        // bytecode generated using: easm test/opcodes/push5
        (bool success, bytes memory data) = hyvm.delegatecall(hex"64ffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffff);
    }

    function testPush6() public {
        // bytecode generated using: easm test/opcodes/push6
        (bool success, bytes memory data) = hyvm.delegatecall(hex"65ffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffff);
    }

    function testPush7() public {
        // bytecode generated using: easm test/opcodes/push7
        (bool success, bytes memory data) = hyvm.delegatecall(hex"66ffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffff);
    }

    function testPush8() public {
        // bytecode generated using: easm test/opcodes/push8
        (bool success, bytes memory data) = hyvm.delegatecall(hex"67ffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffff);
    }

    function testPush9() public {
        // bytecode generated using: easm test/opcodes/push9
        (bool success, bytes memory data) = hyvm.delegatecall(hex"68ffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffff);
    }

    function testPush10() public {
        // bytecode generated using: easm test/opcodes/push10
        (bool success, bytes memory data) = hyvm.delegatecall(hex"69ffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffff);
    }

    function testPush11() public {
        // bytecode generated using: easm test/opcodes/push11
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6affffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffff);
    }

    function testPush12() public {
        // bytecode generated using: easm test/opcodes/push12
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6bffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffff);
    }

    function testPush13() public {
        // bytecode generated using: easm test/opcodes/push13
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6cffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffff);
    }

    function testPush14() public {
        // bytecode generated using: easm test/opcodes/push14
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6dffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffff);
    }

    function testPush15() public {
        // bytecode generated using: easm test/opcodes/push15
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6effffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffff);
    }

    function testPush16() public {
        // bytecode generated using: easm test/opcodes/push16
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6fffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffff);
    }

    function testPush17() public {
        // bytecode generated using: easm test/opcodes/push17
        (bool success, bytes memory data) = hyvm.delegatecall(hex"70ffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffff);
    }

    function testPush18() public {
        // bytecode generated using: easm test/opcodes/push18
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"71ffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffff);
    }

    function testPush19() public {
        // bytecode generated using: easm test/opcodes/push19
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"72ffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffff);
    }

    function testPush20() public {
        // bytecode generated using: easm test/opcodes/push20
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"73ffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x00ffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush21() public {
        // bytecode generated using: easm test/opcodes/push21
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"74ffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush22() public {
        // bytecode generated using: easm test/opcodes/push22
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"75ffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush23() public {
        // bytecode generated using: easm test/opcodes/push23
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"76ffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush24() public {
        // bytecode generated using: easm test/opcodes/push24
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"77ffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush25() public {
        // bytecode generated using: easm test/opcodes/push25
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"78ffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush26() public {
        // bytecode generated using: easm test/opcodes/push26
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"79ffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush27() public {
        // bytecode generated using: easm test/opcodes/push27
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7affffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush28() public {
        // bytecode generated using: easm test/opcodes/push28
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush29() public {
        // bytecode generated using: easm test/opcodes/push29
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7cffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush30() public {
        // bytecode generated using: easm test/opcodes/push30
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7dffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush31() public {
        // bytecode generated using: easm test/opcodes/push31
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7effffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testPush32() public {
        // bytecode generated using: easm test/opcodes/push32
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testDup1() public {
        // bytecode generated using: easm test/opcodes/dup1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60018060005260205260ff6000f3");
        assertEq(success, true);
        // we store the 2 to be sure the opcode worked
        // in following dups we will not need this as there is several instructions between
        // the opcode and the dup
        (uint256 opcode, uint256 dup1) = abi.decode(data, (uint256, uint256));
        assertEq(opcode, 0x1);
        assertEq(dup1, 0x1);
    }

    function testDup2() public {
        // bytecode generated using: easm test/opcodes/dup2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600160008160005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x1);
    }

    function testDup3() public {
        // bytecode generated using: easm test/opcodes/dup3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6002600160008260005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x2);
    }

    function testDup4() public {
        // bytecode generated using: easm test/opcodes/dup4
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60036002600160008360005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x3);
    }

    function testDup5() public {
        // bytecode generated using: easm test/opcodes/dup5
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600460036002600160008460005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x4);
    }

    function testDup6() public {
        // bytecode generated using: easm test/opcodes/dup6
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6005600460036002600160008560005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x5);
    }

    function testDup7() public {
        // bytecode generated using: easm test/opcodes/dup7
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60066005600460036002600160008660005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x6);
    }

    function testDup8() public {
        // bytecode generated using: easm test/opcodes/dup8
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600760066005600460036002600160008760005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x7);
    }

    function testDup9() public {
        // bytecode generated using: easm test/opcodes/dup9
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"6008600760066005600460036002600160008860005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x8);
    }

    function testDup10() public {
        // bytecode generated using: easm test/opcodes/dup10
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"60096008600760066005600460036002600160008960005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x9);
    }

    function testDup11() public {
        // bytecode generated using: easm test/opcodes/dup11
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600a60096008600760066005600460036002600160008a60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xa);
    }

    function testDup12() public {
        // bytecode generated using: easm test/opcodes/dup12
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600b600a60096008600760066005600460036002600160008b60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xb);
    }

    function testDup13() public {
        // bytecode generated using: easm test/opcodes/dup13
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600c600b600a60096008600760066005600460036002600160008c60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xc);
    }

    function testDup14() public {
        // bytecode generated using: easm test/opcodes/dup14
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600d600c600b600a60096008600760066005600460036002600160008d60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xd);
    }

    function testDup15() public {
        // bytecode generated using: easm test/opcodes/dup15
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600e600d600c600b600a60096008600760066005600460036002600160008e60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xe);
    }

    function testDup16() public {
        // bytecode generated using: easm test/opcodes/dup16
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600f600e600d600c600b600a60096008600760066005600460036002600160008f60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xf);
    }

    function testSwap1() public {
        // bytecode generated using: easm test/opcodes/swap1
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600260019060005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x2);
    }

    function testSwap2() public {
        // bytecode generated using: easm test/opcodes/swap2
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6003600260019160005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x3);
    }

    function testSwap3() public {
        // bytecode generated using: easm test/opcodes/swap3
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60046003600260019260005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x4);
    }

    function testSwap4() public {
        // bytecode generated using: easm test/opcodes/swap4
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600560046003600260019360005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x5);
    }

    function testSwap5() public {
        // bytecode generated using: easm test/opcodes/swap5
        (bool success, bytes memory data) = hyvm.delegatecall(hex"6006600560046003600260019460005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x6);
    }

    function testSwap6() public {
        // bytecode generated using: easm test/opcodes/swap6
        (bool success, bytes memory data) = hyvm.delegatecall(hex"60076006600560046003600260019560005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x7);
    }

    function testSwap7() public {
        // bytecode generated using: easm test/opcodes/swap7
        (bool success, bytes memory data) = hyvm.delegatecall(hex"600860076006600560046003600260019660005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x8);
    }

    function testSwap8() public {
        // bytecode generated using: easm test/opcodes/swap8
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"6009600860076006600560046003600260019760005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x9);
    }

    function testSwap9() public {
        // bytecode generated using: easm test/opcodes/swap9
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600a6009600860076006600560046003600260019860005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xa);
    }

    function testSwap10() public {
        // bytecode generated using: easm test/opcodes/swap10
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600b600a6009600860076006600560046003600260019960005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xb);
    }

    function testSwap11() public {
        // bytecode generated using: easm test/opcodes/swap11
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600c600b600a6009600860076006600560046003600260019a60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xc);
    }

    function testSwap12() public {
        // bytecode generated using: easm test/opcodes/swap12
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600d600c600b600a6009600860076006600560046003600260019b60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xd);
    }

    function testSwap13() public {
        // bytecode generated using: easm test/opcodes/swap13
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600e600d600c600b600a6009600860076006600560046003600260019c60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xe);
    }

    function testSwap14() public {
        // bytecode generated using: easm test/opcodes/swap14
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"600f600e600d600c600b600a6009600860076006600560046003600260019d60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0xf);
    }

    function testSwap15() public {
        // bytecode generated using: easm test/opcodes/swap15
        (bool success, bytes memory data) =
            hyvm.delegatecall(hex"6010600f600e600d600c600b600a6009600860076006600560046003600260019e60005260ff6000f3");
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x10);
    }

    function testSwap16() public {
        // bytecode generated using: easm test/opcodes/swap16
        (bool success, bytes memory data) = hyvm.delegatecall(
            hex"60116001600f600e600d600c600b600a6009600860076006600560046003600260019f60005260ff6000f3"
        );
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x11);
    }

    function testCall() public {
        address calldatacontract;
        assembly {
            // use scratch space
            mstore(0, 0x67600035600757FE5B60005260086018F3) // see opcodes/contracts/callContract
            calldatacontract := create(0, 15, 17)
        }
        // bytecode generated using: easm test/opcodes/call
        bytes memory bytecode =
            hex"60016000526000600060206000600073123123123123123123123123123123123123123161fffff160005260ff6000f3";
        // we replace the dummy address with actual contract address
        bytecode = Utils.replace(bytecode, 0x1231231231231231231231231231231231231231, calldatacontract);
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        (uint256 result) = abi.decode(data, (uint256));
        assertEq(result, 0x1);
    }

    function testCallFail() public {
        address calldatacontract;
        assembly {
            // use scratch space
            mstore(0, 0x67600035600757FE5B60005260086018F3) // see opcodes/contracts/callContract
            calldatacontract := create(0, 15, 17)
        }
        // bytecode generated using: easm test/opcodes/callFail
        bytes memory bytecode =
            hex"6000600060006000600073123123123123123123123123123123123123123161fffff160005260ff6000f3";
        // we replace the dummy address with actual contract address
        bytecode = Utils.replace(bytecode, 0x1231231231231231231231231231231231231231, calldatacontract);
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x0);
    }

    function testDelegateCall() public {
        address calldatacontract;
        assembly {
            // use scratch space
            mstore(0, 0x67600054600757FE5B60005260086018F3) // see opcodes/contracts/exceptionIfFirstSlotStorageIs0
            calldatacontract := create(0, 15, 17)
        }
        // bytecode generated using: easm test/opcodes/delegateCall
        bytes memory bytecode =
            hex"60016000556000600060006000600073123123123123123123123123123123123123123161fffff460005260ff6000f3";
        // we replace the dummy address with actual contract address
        bytecode = Utils.replace(bytecode, 0x1231231231231231231231231231231231231231, calldatacontract);
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x1);
    }

    function testDelegateCallFail() public {
        address calldatacontract;
        assembly {
            // use scratch space
            mstore(0, 0x67600054600757FE5B60005260086018F3) // see opcodes/contracts/exceptionIfFirstSlotStorageIs0
            calldatacontract := create(0, 15, 17)
        }
        // bytecode generated using: easm test/opcodes/delegateCallFail
        bytes memory bytecode =
            hex"60006000556000600060006000600073123123123123123123123123123123123123123161fffff460005260ff6000f3";
        // we replace the dummy address with actual contract address
        bytecode = Utils.replace(bytecode, 0x1231231231231231231231231231231231231231, calldatacontract);
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x0);
    }

    function testCreate() public {
        // bytecode generated using: easm test/opcodes/create
        bytes memory bytecode = hex"7067600054600757fe5b60005260086018f36000526011600f6000f060005260ff6000f3";
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        // It send us back an address
        (address result) = abi.decode(data, (address));
        // Let's verify that the code present is exceptionIfFirstSlotStorageIs0 bytecode
        bytes memory code = result.code;
        assertEq(code, hex"600054600757fe5b");
    }

    function testCreate2() public {
        // bytecode generated using: easm test/opcodes/create2
        bytes memory cont = hex"7067600054600757fe5b60005260086018f360005260016011600f6000f060005260ff6000f3";
        // we replace create opcode by create2 as EVM-Assembler does not implement it
        bytes memory bytecode = Utils.replaceFirstOccurenceBytes(cont, hex"f0", hex"f5");
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        assertEq(success, true);
        // It send us back an address
        (address result) = abi.decode(data, (address));
        // Let's verify that the code present is exceptionIfFirstSlotStorageIs0 bytecode
        bytes memory code = result.code;
        assertEq(code, hex"600054600757fe5b");
    }

    function testCannotCallHyVM() public {
        bytes memory bytecode = hex"60ff60005260ff6000f3";
        // bytecode generated using: easm test/opcodes/push1
        (bool success, bytes memory data) = hyvm.delegatecall(bytecode);
        // success in delegatecall
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
        // revert in call
        vm.expectRevert();
        (success, ) = hyvm.call(bytecode);
        assertTrue(success, "expectRevert: call did not revert");
        // revert in staticcal
        vm.expectRevert();
        (success, ) = hyvm.staticcall(bytecode);
        assertTrue(success, "expectRevert: call did not revert");
    }

    function testCallcodeNotSupported() public {
        address calldatacontract;
        assembly {
            // use scratch space
            mstore(0, 0x67600054600757FE5B60005260086018F3) // see opcodes/contracts/exceptionIfFirstSlotStorageIs0
            calldatacontract := create(0, 15, 17)
        }
        // bytecode generated using: easm test/opcodes/callcode
        // should revert without an error message
        bytes memory bytecode =
            hex"60016000556000600060006000600073123123123123123123123123123123123123123161fffff260005260ff6000f3";
        // we replace the dummy address with actual contract address
        bytecode = Utils.replace(bytecode, 0x1231231231231231231231231231231231231231, calldatacontract);
        vm.expectRevert(bytes(""));
        (bool success, ) = hyvm.delegatecall(bytecode);
        assertTrue(success, "expectRevert: call did not revert");
    }

    function testPCRetrievalByOverFlow() public {
        // bytecode generated using: easm test/opcodes/pc-retrieval-by-overflow
        // simple mstore that will go too far in memory
        vm.expectRevert(bytes(""));
        (bool success,) = hyvm.delegatecall(
            hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff51"
        );
        assertTrue(success, "expectRevert: call did not revert");
    }
}
