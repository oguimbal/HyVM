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
    address ZERO_ADDRESS = address(0);
    uint256 balance = 1000 * 1e6;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant USDC_owner = 0x524a464E53208c1f87F6D56119aCb667D042491a;
    CallHyvm callHyvm;
    bytes multiplSwapHyvmBytecode;

    // Labels
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant WBNB = 0x418D75f65a02b3D53B2418FB8E1fe493759c7605;
    address private constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    IUniswapV2Router01 private constant uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(
            vm.rpcUrl('eth')
        );
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();
        
        deal(USDC, address(callHyvm), 100_000_000);
        deal(USDC, address(this), 100_000_000);

        multiplSwapHyvmBytecode = getMultipleSwapBytecode();

        // Debug labels
        vm.label(USDC, "USDC");
        vm.label(DAI, "DAI");
        vm.label(WETH, "WETH");
        vm.label(WBTC, "WBTC");
        vm.label(WBNB, "WBNB");
        vm.label(AAVE, "AAVE");
        vm.label(address(uniswapRouter), "uniswapRouter");
    }

    function getMultipleSwapBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/limitTesting/MultipleSwap_hyvm.sol | head -12 | tail -1)';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    function testMultipleSwaps() public {
        callHyvm.callHyvm(hyvm, multiplSwapHyvmBytecode);
    }

}