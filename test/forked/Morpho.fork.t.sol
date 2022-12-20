// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

import {ILens} from "./calls/morpho/ILens.sol";
import {SupplyBorrowMorpho} from "./calls/morpho/SupplyBorrowMorpho.sol";
import {CallHyvm} from "./calls/CallHyvm.sol";

import {Utils} from "../utils/Utils.sol";
import {cDAI, cUSDC, DAI, USDC} from "./ConstantsEthereum.sol";

contract MorphoTests is Test {
    address hyvm;
    address owner;
    CallHyvm callHyvm;

    bytes supplyBorrowMorphoHyvmBytecode;
    SupplyBorrowMorpho supplyBorrowMorpho;
    ILens lens = ILens(0x930f1b46e1D081Ec1524efD95752bE3eCe51EF67);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();

        supplyBorrowMorphoHyvmBytecode = type(SupplyBorrowMorpho).runtimeCode;
        supplyBorrowMorpho = new SupplyBorrowMorpho();
    }

    receive() external payable {}

    function testSupplyBorrowMorphoHyvm() public {
        deal(DAI, address(callHyvm), 100_000_000 * 10 ** 18);
        // replace "supplyBorrowMorpho" selector and bypass calldata size check
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = DAI;
        (,, uint256 totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callHyvm));
        (,, uint256 totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callHyvm));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        bytes memory finalBytecode =
            Utils.replaceSelectorBypassCalldataSizeCheck(supplyBorrowMorphoHyvmBytecode, hex"b9ab7b77");
        callHyvm.callHyvm(hyvm, finalBytecode);
        (,, totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callHyvm));
        (,, totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callHyvm));
        assertEq(totalBalanceUSDC >= 98 * 10 ** 5, true);
        assertEq(totalBalanceDAI >= 998 * 10 ** 18, true);
    }

    function testSupplyBorrowMorphoNative() public {
        deal(DAI, address(supplyBorrowMorpho), 100_000_000 * 10 ** 18);
        (,, uint256 totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(supplyBorrowMorpho));
        (,, uint256 totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(supplyBorrowMorpho));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        supplyBorrowMorpho.supplyBorrowMorpho();
        (,, totalBalanceUSDC) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(supplyBorrowMorpho));
        (,, totalBalanceDAI) = lens.getCurrentSupplyBalanceInOf(cDAI, address(supplyBorrowMorpho));
        assertEq(totalBalanceUSDC >= 98 * 10 ** 5, true);
        assertEq(totalBalanceDAI >= 998 * 10 ** 18, true);
    }
}
