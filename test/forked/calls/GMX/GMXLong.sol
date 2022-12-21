// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import {IERC20} from "../../../utils/interfaces/IERC20.sol";
import {USDC, WETH} from "./../../ConstantsArbitrum.sol";

import {IGMXPositionRouter, IGMXRouter} from "./IGMX.sol";

contract GMXLong {
    uint256 private constant amountUSDC = 1000 * 10 ** 6;
    IGMXRouter private constant GMXRouter = IGMXRouter(0xaBBc5F99639c9B6bCb58544ddf04EFA6802F4064);
    IGMXPositionRouter private constant positionRouter = IGMXPositionRouter(0xb87a436B93fFE9D75c5cFA7bAcFff96430b09868);

    constructor() {}

    function gmxLong() public {
        IERC20(USDC).approve(address(GMXRouter), type(uint256).max);
        IERC20(USDC).approve(address(positionRouter), type(uint256).max);
        GMXRouter.approvePlugin(address(positionRouter));
        // USD amounts are multiplied by (10 ** 30)
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = WETH;
        positionRouter.createIncreasePosition{value: 3000_000_000_000_000}(
            path, // [tokenIn, collateralToken] _path
            WETH, // _indexToken (token we want to long)
            100 * 10 ** 6, // _amountIn
            0, // minOut
            600 * 10 ** 30, // _sizeDelta  the USD value of the change in position size
            true, // _isLong
            3000 * 10 ** 30, // _acceptablePrice
            3000_000_000_000_000, // _executionFee
            bytes32(0), // _referralCode
            address(0) // _callbackTarget
        );
    }

    receive() external payable {}
}
