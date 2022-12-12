// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import {IUniswapV2Router01} from "../utils/interfaces/IUniswapV2Router01.sol";
import {IERC20} from "../utils/interfaces/IERC20.sol";

contract DoubleSwap {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IUniswapV2Router01 private constant uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private constant amountUSDC = 100_000_000;
    constructor(){}

    function doubleSwap() public {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        require(balance >= amountUSDC, 'Not enough $');
        IERC20(USDC).approve(address(uniswapRouter), type(uint256).max);
        uint256 ethBalanceBefore = address(this).balance;
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = WETH;
        uniswapRouter.swapExactTokensForETH(amountUSDC, 0, path, address(this), block.timestamp);
        uint256 ethafter = address(this).balance - ethBalanceBefore;
        uint256 daiBefore = IERC20(DAI).balanceOf(address(this));
        path[0] = WETH;
        path[1] = DAI;
        uniswapRouter.swapExactETHForTokens{value: ethafter}(0, path, address(this), block.timestamp);
        uint256 daiAfter = IERC20(DAI).balanceOf(address(this)) - daiBefore;
        require(daiAfter >= 9800000000000000);
    }

    receive() external payable {}
}
