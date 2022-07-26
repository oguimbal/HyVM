// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import './Utils.sol';

contract OpcodesTest is Test {
    address public nvm;

    function setUp() public {
        nvm = HuffDeployer.deploy("NVM");
    }


    // =============== UTILITIES =================

    function logStr(string memory str) public view {
        console.log(Utils.iToHex(abi.encodePacked(str), 32));
        console.log(Utils.iToHex(abi.encodePacked(bytes(str).length)));
    }

    // just a test that shows what to write in NVM.huff to console.log something.
    function testGenerate() public view {
        logStr('no call verifier set');
    }




    // =================== TESTS ==============

    function testPushReturnMstore() public {
        // bytecode generated using: easm test/bytecode/push
        // ... which is 3+4
        (bool success, bytes memory data) = nvm.delegatecall(
            hex"7fff0100000000000000000000000000000000000000000000000000000000000060005260026000f3"
        );
        assertEq(success, true);
        assertEq(data, hex'ff01');
    }



    function testAdd() public {
        // bytecode generated using: easm test/bytecode/add
        // ... which is 3+4
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360040160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 7);
    }

    function testMul() public {
        // bytecode generated using: easm test/bytecode/mul
        // ... which is 3*4
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360040260005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 12);
    }

    function testSub() public {
        // bytecode generated using: easm test/bytecode/sub
        // ... which is 7-3
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360070360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }

    function testDiv() public {
        // bytecode generated using: easm test/bytecode/div
        // ... which is 15/3
        (bool success, bytes memory data) = nvm.delegatecall(hex"6003600f0460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 5);
    }

    function testSDiv() public {
        // bytecode generated using: easm test/bytecode/sdiv
        // ... which is 16//3
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360100560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 5);
    }

    function testMod() public {
        // bytecode generated using: easm test/bytecode/mod
        // ... which is 16%3
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360100660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSMod() public {
        // bytecode generated using: easm test/bytecode/smod
        // ... which is 16%%3
        (bool success, bytes memory data) = nvm.delegatecall(hex"600360100760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testAddmod() public {
        // bytecode generated using: easm test/bytecode/addmod
        (bool success, bytes memory data) = nvm.delegatecall(hex"6008600a600a0860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }

    function testMulmod() public {
        // bytecode generated using: easm test/bytecode/mulmod
        (bool success, bytes memory data) = nvm.delegatecall(hex"6008600a600a0960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 4);
    }


    function testExp() public {
        // bytecode generated using: easm test/bytecode/exp
        (bool success, bytes memory data) = nvm.delegatecall(hex"6002600a0a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x64);
    }

    function testSignExtend() public {
        // bytecode generated using: easm test/bytecode/signextend
        (bool success, bytes memory data) = nvm.delegatecall(hex"60ff60000b60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testLt1() public {
        // bytecode generated using: easm test/bytecode/lt-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060091060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testLt2() public {
        // bytecode generated using: easm test/bytecode/lt-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060101060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testGt1() public {
        // bytecode generated using: easm test/bytecode/gt-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"600960101160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testGt2() public {
        // bytecode generated using: easm test/bytecode/gt-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060101060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testSlt1() public {
        // bytecode generated using: easm test/bytecode/slt-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"60097fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff1260005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSlt2() public {
        // bytecode generated using: easm test/bytecode/slt-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060101260005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testSgt1() public {
        // bytecode generated using: easm test/bytecode/sgt-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60091360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSgt2() public {
        // bytecode generated using: easm test/bytecode/sgt-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060101360005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testEq1() public {
        // bytecode generated using: easm test/bytecode/eq-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"601060101460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testEq2() public {
        // bytecode generated using: easm test/bytecode/eq-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"600560101460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testIsZero1() public {
        // bytecode generated using: easm test/bytecode/iszero-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"60101560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testIsZero2() public {
        // bytecode generated using: easm test/bytecode/iszero-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"60001560005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }



    function testAnd1() public {
        // bytecode generated using: easm test/bytecode/and-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"600f600f1660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x0f);
    }

    function testAnd2() public {
        // bytecode generated using: easm test/bytecode/and-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"600060ff1660005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testOr1() public {
        // bytecode generated using: easm test/bytecode/or-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"60f0600f1760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testOr2() public {
        // bytecode generated using: easm test/bytecode/or-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"60ff60ff1760005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testXor1() public {
        // bytecode generated using: easm test/bytecode/xor-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"600f60f01860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testXor2() public {
        // bytecode generated using: easm test/bytecode/xor-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"60ff60ff1860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x00);
    }

    function testNot() public {
        // bytecode generated using: easm test/bytecode/not
        (bool success, bytes memory data) = nvm.delegatecall(hex"60001960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    }

    function testByte1() public {
        // bytecode generated using: easm test/bytecode/byte-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"60ff601f1a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xff);
    }

    function testByte2() public {
        // bytecode generated using: easm test/bytecode/byte-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"60ff601e1a60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testShl() public {
        // bytecode generated using: easm test/bytecode/shl
        (bool success, bytes memory data) = nvm.delegatecall(hex"600160011b60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 2);
    }

    function testShr() public {
        // bytecode generated using: easm test/bytecode/shr
        (bool success, bytes memory data) = nvm.delegatecall(hex"600260011c60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSar() public {
        // bytecode generated using: easm test/bytecode/sar
        (bool success, bytes memory data) = nvm.delegatecall(hex"600260011d60005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testSha3() public {
        // bytecode generated using: easm test/bytecode/sha3
        (bool success, bytes memory data) = nvm.delegatecall(hex"7fffffffff00000000000000000000000000000000000000000000000000000000600052600460002060005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        // weird... the playground does not return this hash (but this is a hash)
        assertEq(result, 105345537983141833900523177836038591426164988092870088428104961074093597336652);
    }


    function testAddress() public {
        // bytecode generated using: easm test/bytecode/address
        (bool success, bytes memory data) = nvm.delegatecall(hex"3060005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, address(this));
    }


    function testBalance() public {
        // bytecode generated using: easm test/bytecode/balance
        (bool success, bytes memory data) = nvm.delegatecall(hex"303160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0xFFFFFFFFFFFFFFFFFFFFFFFF);
    }

    function testOrigin() public {
        // bytecode generated using: easm test/bytecode/origin
        (bool success, bytes memory data) = nvm.delegatecall(hex"3260005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, 0x00a329c0648769A73afAc7F9381E08FB43dBEA72);
    }

    function testCaller() public {
        // bytecode generated using: easm test/bytecode/caller
        (bool success, bytes memory data) = nvm.delegatecall(hex"3360005260ff6000f3");
        assertEq(success, true);
        address result = abi.decode(data, (address));
        assertEq(result, 0x00a329c0648769A73afAc7F9381E08FB43dBEA72);
    }

    function testCallvalue() public {
        // bytecode generated using: easm test/bytecode/callvalue
        (bool success, bytes memory data) = nvm.delegatecall(hex"3460005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }


    function testPc1() public {
        // bytecode generated using: easm test/bytecode/pc-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"5860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testPc2() public {
        // bytecode generated using: easm test/bytecode/pc-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"5b5860005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 1);
    }

    function testPc3() public {
        // bytecode generated using: easm test/bytecode/pc-3
        (bool success, bytes memory data) = nvm.delegatecall(hex"58585b5b5b58010160005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 6);
    }

    function testMsize1() public {
        // bytecode generated using: easm test/bytecode/msize-1
        (bool success, bytes memory data) = nvm.delegatecall(hex"5960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0);
    }

    function testMsize2() public {
        // bytecode generated using: easm test/bytecode/msize-2
        (bool success, bytes memory data) = nvm.delegatecall(hex"600051505960005260ff6000f3");
        assertEq(success, true);
        uint256 result = abi.decode(data, (uint256));
        assertEq(result, 0x20);
    }
}
