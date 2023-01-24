// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.16;

interface ILens {
    function getCurrentBorrowBalanceInOf(address _poolTokenAddress, address _user)
        external
        returns (uint256 balanceOnPool, uint256 balanceInP2P, uint256 totalBalance);

    function getCurrentSupplyBalanceInOf(address _poolTokenAddress, address _user)
        external
        returns (uint256 balanceOnPool, uint256 balanceInP2P, uint256 totalBalance);
}
