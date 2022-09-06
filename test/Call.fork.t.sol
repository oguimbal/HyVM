// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./Utils.sol";
import "./CallVerifiers.sol";

import "./calls/IERC20.sol";

import "./calls/DoubleSwap_native.sol";
import "./calls/CallNvm.sol";

contract DoubleSwapTest is Test {
    address nvm;
    address doubleSwapHuff;
    address owner;
    address ZERO_ADDRESS = address(0);
    uint256 balance = 1000 * 1e6;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC_owner = 0x524a464E53208c1f87F6D56119aCb667D042491a;
    DoubleSwap doubleSwap;
    CallNvm callNvm;
    bytes doubleswapNvmBytecode;

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(
            vm.rpcUrl('eth')
        );
        owner = address(this);
        nvm = HuffDeployer.deploy("NVM");
        doubleSwapHuff = HuffDeployer.deploy("../test/calls/DoubleSwap");
        doubleSwap = new DoubleSwap();
        callNvm = new CallNvm();
        vm.startPrank(USDC_owner, USDC_owner);
        IERC20(USDC).transfer(address(doubleSwap), 100_000_000);
        IERC20(USDC).transfer(address(callNvm), 100_000_000);
        IERC20(USDC).transfer(address(this), 100_000_000);
        vm.stopPrank();
        doubleswapNvmBytecode = getBytecode();
    }

    receive() external payable {}

    function getBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/DoubleSwap_nvm.sol | head -4 | tail -1)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    // TODO write tests for all kind of calls (as time of writing, only CALL & STATICCALL are tested, but we must also test DELEGATECALL & CALLCODE)

    function testDoubleSwap_native_solidity() public {
        doubleSwap.doubleSwap();
    }

    function testDoubleSwap_nvm_solidity() public {
        callNvm.callNvm(nvm, doubleswapNvmBytecode);
    }

    function testDoubleSwap_native_huff() public {
        (bool success,) = doubleSwapHuff.delegatecall(new bytes(0));
        assertEq(success, true);
    }

    function testDoubleSwap_nvm_huff() public {
        callNvm.callNvm(nvm, doubleSwapHuff.code);
    }
}
