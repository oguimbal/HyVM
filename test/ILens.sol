// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

interface ILens {
    function getCurrentBorrowBalanceInOf(
        address _poolTokenAddress,
        address _user
    )
        external
        returns (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        );

    function getCurrentSupplyBalanceInOf(
        address _poolTokenAddress,
        address _user
    )
        external
        returns (
            uint256 balanceOnPool,
            uint256 balanceInP2P,
            uint256 totalBalance
        );
}
