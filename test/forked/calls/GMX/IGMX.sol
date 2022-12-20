// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

interface IGMXPositionRouter {
    function createIncreasePosition(
        address[] memory _path,
        address _indexToken,
        uint256 _amountIn,
        uint256 _minOut,
        uint256 _sizeDelta,
        bool _isLong,
        uint256 _acceptablePrice,
        uint256 _executionFee,
        bytes32 _referralCode,
        address _callbackTarget
    )
        external
        payable;

    function executeIncreasePosition(bytes32 _key, address payable _executionFeeReceiver) external returns (bool);
    function getRequestKey(address _account, uint256 _index) external pure returns (bytes32);
    function setPositionKeeper(address _account, bool _isActive) external;
}

interface IGMXRouter {
    function approvePlugin(address _plugin) external;
}
