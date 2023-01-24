// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {DepositBorrowAave} from "./calls/aave/DepositBorrowAave.sol";
import {ILendingPool} from "./calls/aave/ILendingPool.sol";
import {CallHyvm} from "./calls/CallHyvm.sol";

import {Utils} from "../utils/Utils.sol";
import {USDC} from "./ConstantsEthereum.sol";

contract AaveTests is Test {
    address hyvm;
    address owner;
    CallHyvm callHyvm;

    bytes depositBorrowAaveHyvmBytecode;
    DepositBorrowAave depositBorrowAave;
    ILendingPool lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();

        depositBorrowAaveHyvmBytecode = type(DepositBorrowAave).runtimeCode;
        depositBorrowAave = new DepositBorrowAave();
    }

    receive() external payable {}

    function testDepositBorrowAaveHyvm() public {
        deal(USDC, address(callHyvm), 100_000_000 * 10 ** 6);
        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
        ) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        // replace "depositBorrowAave" selector and bypass calldata size check
        bytes memory finalBytecode =
            Utils.replaceSelectorBypassCalldataSizeCheck(depositBorrowAaveHyvmBytecode, hex"d280ed95");
        callHyvm.callHyvm(hyvm, finalBytecode);
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv,) =
            lendingPool.getUserAccountData(address(callHyvm));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0, true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }

    function testDepositBorrowAaveNative() public {
        deal(USDC, address(depositBorrowAave), 100_000_000 * 10 ** 6);
        (
            uint256 totalCollateralETH,
            uint256 totalDebtETH,
            uint256 availableBorrowsETH,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
        ) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        depositBorrowAave.depositBorrowAave();
        (totalCollateralETH, totalDebtETH, availableBorrowsETH, currentLiquidationThreshold, ltv,) =
            lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0, true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }
}
