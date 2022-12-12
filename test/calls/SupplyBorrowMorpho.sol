// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import {IERC20} from "../utils/interfaces/IERC20.sol";
import "./IMorpho.sol";
import "../ConstantsEthereum.sol";

contract SupplyBorrowMorpho {
    IMorpho private constant morpho =
        IMorpho(0x8888882f8f843896699869179fB6E4f7e3B58888);
    uint256 private constant amountDAI = 1_000 * 10**18;

    constructor() {}

    function supplyBorrowMorpho() public {
        uint256 balance = IERC20(DAI).balanceOf(address(this));
        require(balance >= amountDAI, "Not enough $");

        // Approve Morpho contract to move DAI
        IERC20(DAI).approve(address(morpho), amountDAI);
        // balance DAI before
        uint256 DAIBalanceBefore = IERC20(DAI).balanceOf(address(this));
        // Supply DAI: we do not receive a token in exchange. Position is tracked by
        // morpho in storage. Morpho receive the interest bearing token.
        morpho.supply(cDAI, address(this), amountDAI);
        // balance DAI after supply
        uint256 DAIBalanceAfter = IERC20(DAI).balanceOf(address(this));
        // check slippage
        require(DAIBalanceBefore - DAIBalanceAfter >= amountDAI);
        // balance USDC before
        uint256 USDCBalanceBefore = IERC20(USDC).balanceOf(address(this));
        // borrow 10 USDC
        morpho.borrow(cUSDC, 10 * 10**6);
        // balance after borrow
        uint256 USDCBalanceAfter = IERC20(USDC).balanceOf(address(this));
        // check borrowed amount
        require(USDCBalanceAfter - USDCBalanceBefore >= 98 * 10**5);
    }
}
