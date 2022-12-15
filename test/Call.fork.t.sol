// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {IERC20} from "./utils/interfaces/IERC20.sol";

import "./calls/DoubleSwap.sol";
import "./calls/CallHyvm.sol";

import "./calls/SupplyBorrowMorpho.sol";
import "./calls/DepositBorrowAave.sol";

import {Utils} from "./utils/Utils.sol";
import "./ConstantsEthereum.sol";

import "./ILens.sol";

contract CallForkTests is Test {
    address hyvm;
    address doubleSwapHuff;
    address owner;
    uint256 balance = 1000 * 1e6;
    DoubleSwap doubleSwap;
    CallHyvm callHyvm;
    bytes doubleswapHyvmBytecode;
    bytes depositBorrowAaveHyvmBytecode;
    bytes supplyBorrowMorphoHyvmBytecode;
    SupplyBorrowMorpho supplyBorrowMorpho;
    DepositBorrowAave depositBorrowAave;

    ILendingPool lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    ILens lens = ILens(0x930f1b46e1D081Ec1524efD95752bE3eCe51EF67);

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        doubleSwapHuff = HuffDeployer.deploy("../test/calls/DoubleSwap");
        doubleSwap = new DoubleSwap();
        callHyvm = new CallHyvm();

        doubleswapHyvmBytecode = type(DoubleSwap).runtimeCode;
        depositBorrowAaveHyvmBytecode = type(DepositBorrowAave).runtimeCode;
        supplyBorrowMorphoHyvmBytecode = type(SupplyBorrowMorpho).runtimeCode;

        supplyBorrowMorpho = new SupplyBorrowMorpho();
        depositBorrowAave = new DepositBorrowAave();
    }

    receive() external payable {}

    // TODO write tests for all kind of calls (as time of writing, only CALL & STATICCALL are tested, but we must also test DELEGATECALL & CALLCODE)

    function testDoubleSwap_native_solidity() public {
        deal(USDC, address(doubleSwap), 100_000_000 * 10**6);
        doubleSwap.doubleSwap();
    }

    function testDoubleSwap_hyvm_solidity() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10**6);
        // replace "doubleSwap" selector and bypass calldata size check
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                doubleswapHyvmBytecode,
                hex"64c2c785"
            );
        callHyvm.callHyvm(hyvm, finalBytecode);
        require(IERC20(DAI).balanceOf(address(callHyvm)) >= 9800000000000000);
    }

    function testDoubleSwap_native_huff() public {
        deal(USDC, address(this), 100_000_000 * 10**6);
        (bool success, ) = doubleSwapHuff.delegatecall(new bytes(0));
        assertEq(success, true);
        require(IERC20(DAI).balanceOf(address(this)) >= 9800000000000000);
    }

    function testDoubleSwap_hyvm_huff() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10**6);
        callHyvm.callHyvm(hyvm, doubleSwapHuff.code);
        require(IERC20(DAI).balanceOf(address(callHyvm)) >= 9800000000000000);
    }

    function testDepositBorrowAaveHyvm() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10**6);
        (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        // replace "depositBorrowAave" selector and bypass calldata size check
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                depositBorrowAaveHyvmBytecode,
                hex"d280ed95"
            );
        callHyvm.callHyvm(hyvm, finalBytecode);
        (totalCollateralETH,  totalDebtETH,  availableBorrowsETH,  currentLiquidationThreshold,  ltv, ) = lendingPool.getUserAccountData(address(callHyvm));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0 , true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }

    function testDepositBorrowAaveNative() public {
        deal(USDC, address(depositBorrowAave), 100_000_000 * 10**6);
        (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        depositBorrowAave.depositBorrowAave();
        (totalCollateralETH,  totalDebtETH,  availableBorrowsETH,  currentLiquidationThreshold, ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0 , true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }

    function testSupplyBorrowMorphoHyvm() public {
        deal(DAI, address(callHyvm), 100_000_000 * 10**18);
        // replace "supplyBorrowMorpho" selector and bypass calldata size check
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = DAI;
        (,,uint256 totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callHyvm));
        (,,uint256 totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callHyvm));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                supplyBorrowMorphoHyvmBytecode,
                hex"b9ab7b77"
            );
        callHyvm.callHyvm(hyvm, finalBytecode);
        (,,totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callHyvm));
        (,,totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callHyvm));
        assertEq(totalBalanceUSDC >= 98 * 10**5, true);
        assertEq(totalBalanceDAI >=  998 * 10**18, true);
    }

    function testSupplyBorrowMorphoNative() public {
        deal(DAI, address(supplyBorrowMorpho), 100_000_000 * 10**18);
        (,,uint256 totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(supplyBorrowMorpho));
        (,,uint256 totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(supplyBorrowMorpho));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        supplyBorrowMorpho.supplyBorrowMorpho();
        (,,totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(supplyBorrowMorpho));
        (,,totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(supplyBorrowMorpho));
        assertEq(totalBalanceUSDC >= 98 * 10**5, true);
        assertEq(totalBalanceDAI >=  998 * 10**18, true);
    }
}
