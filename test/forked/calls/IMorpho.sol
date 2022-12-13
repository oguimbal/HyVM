// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

interface IMorpho {
    function supply(
        address _poolTokenAddress,
        address _onBehalf,
        uint256 _amount
    ) external;

    function borrow(address _poolTokenAddress, uint256 _amount) external;
}
