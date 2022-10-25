// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "./IERC20.sol";
import "./ILendingPool.sol";
import "../ConstantsEthereum.sol";

contract DepositBorrowAave {
    ILendingPool private constant lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    uint256 private constant amountUSDC = 100 * 10 ** 6;

    constructor() {}

    function depositBorrowAave() public {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        require(balance >= amountUSDC, "Not enough $");
        // approve lending pool
        IERC20(USDC).approve(address(lendingPool), amountUSDC);
        // deposit
        lendingPool.deposit(USDC, amountUSDC, address(this), 0);
        // balance aUSDC after
        uint256 aUSDCBalanceAfter = IERC20(aUSDC).balanceOf(address(this));
        // check slippage
        require(aUSDCBalanceAfter >= 98 * 10 ** 6);
        // balance dai before
        uint256 DaiBalanceBefore = IERC20(DAI).balanceOf(address(this));
        // borrow
        lendingPool.borrow(DAI, 10 * 10 ** 18, 2, 0, address(this));
        // balance dai after
        uint256 DaiBalanceAfter = IERC20(DAI).balanceOf(address(this));
        // check borrowed amount
        require(DaiBalanceAfter - DaiBalanceBefore >= 98 * 10 ** 17);
    }
}
