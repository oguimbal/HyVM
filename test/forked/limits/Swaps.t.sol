// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {CallHyvm} from "../calls/CallHyvm.sol";

import {IERC20} from "../../utils/interfaces/IERC20.sol";
import {IUniswapV2Router01} from "../../utils/interfaces/IUniswapV2Router01.sol";

import {MultipleSwap} from "../calls/limitTesting/MultipleInlineSwaps_hyvm.sol";
import {MultipleLoopedSwap} from "../calls/limitTesting/MultipleLoopedSwaps_hyvm.sol";

contract LimitSwapsTest is Test {
    address hyvm;
    address owner;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    CallHyvm callHyvm;
    bytes multipleInlineSwapHyvmBytecode;
    bytes multipleLoopedSwapHyvmBytecode;

    // Labels
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant WBNB = 0x418D75f65a02b3D53B2418FB8E1fe493759c7605;
    address private constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;
    IUniswapV2Router01 private constant uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.config().with_evm_version("paris").deploy("HyVM");
        callHyvm = new CallHyvm();

        multipleInlineSwapHyvmBytecode = type(MultipleSwap).creationCode;
        multipleLoopedSwapHyvmBytecode = type(MultipleLoopedSwap).creationCode;

        // Debug labels
        vm.label(USDC, "USDC");
        vm.label(DAI, "DAI");
        vm.label(WETH, "WETH");
        vm.label(WBTC, "WBTC");
        vm.label(WBNB, "WBNB");
        vm.label(AAVE, "AAVE");
        vm.label(address(uniswapRouter), "uniswapRouter");
    }

    function testMultipleInlineSwaps() public {
        deal(USDC, address(callHyvm), 100_000_000);
        deal(USDC, address(this), 100_000_000);

        callHyvm.callHyvm(hyvm, multipleInlineSwapHyvmBytecode);
    }

    function testMultipleLoopedSwaps1() public {
        deal(USDC, address(callHyvm), type(uint16).max);
        deal(USDC, address(this), type(uint16).max);

        // Call fail because the uniswap output amount equals 0
        //     => "INSUFFICIENT_OUTPUT_AMOUNT"
        //
        // NOTE: consume 268_920_330 gas
        vm.expectRevert("Failed to call HyVM");
        callHyvm.callHyvm(hyvm, multipleLoopedSwapHyvmBytecode);
    }

    function testMultipleLoopedSwaps2() public {
        deal(USDC, address(callHyvm), type(uint128).max);
        deal(USDC, address(this), type(uint128).max);

        // Call fail because we buy all the ETH in the Uniswap pool
        vm.expectRevert("Failed to call HyVM");
        callHyvm.callHyvm(hyvm, multipleLoopedSwapHyvmBytecode);
    }

    function testMultipleLoopedSwaps3() public {
        deal(USDC, address(callHyvm), type(uint256).max);
        deal(USDC, address(this), type(uint256).max);

        // Call fail because convert uint256.max USDC for ETH, it thorw a
        //     => "ds-math-mul-overflow" during the swap
        vm.expectRevert("Failed to call HyVM");
        callHyvm.callHyvm(hyvm, multipleLoopedSwapHyvmBytecode);
    }
}
