// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import {IUniswapV2Router01} from "../../../utils/interfaces/IUniswapV2Router01.sol";
import {IERC20} from "../../../utils/interfaces/IERC20.sol";

contract MultipleSwap {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address private constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    IUniswapV2Router01 private constant uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private amountUSDC = 100_000_000;

    constructor() {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        require(balance >= amountUSDC, "Not enough $");
        IERC20(USDC).approve(address(uniswapRouter), type(uint256).max);
        IERC20(DAI).approve(address(uniswapRouter), type(uint256).max);
        IERC20(WBTC).approve(address(uniswapRouter), type(uint256).max);
        IERC20(AAVE).approve(address(uniswapRouter), type(uint256).max);

        uint256 ethBalanceBefore = address(this).balance;

        // USDC to ETH
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = WETH;
        uniswapRouter.swapExactTokensForETH(amountUSDC, 0, path, address(this), block.timestamp);

        // ETH to DAI
        path[0] = WETH;
        path[1] = DAI;
        uniswapRouter.swapExactETHForTokens{value: address(this).balance - ethBalanceBefore}(
            0, path, address(this), block.timestamp
        );

        // DAI to WBTC
        uint256 amountDAI = IERC20(DAI).balanceOf(address(this));
        path[0] = DAI;
        path[1] = WBTC;
        uniswapRouter.swapExactTokensForTokens(amountDAI, 0, path, address(this), block.timestamp);

        // WBTC to USDC
        uint256 amountWBTC = IERC20(WBTC).balanceOf(address(this));
        path[0] = WBTC;
        path[1] = USDC;
        uniswapRouter.swapExactTokensForTokens(amountWBTC, 0, path, address(this), block.timestamp);

        ethBalanceBefore = address(this).balance;

        // USDC to ETH
        amountUSDC = IERC20(USDC).balanceOf(address(this));
        path[0] = USDC;
        path[1] = WETH;
        uniswapRouter.swapExactTokensForETH(amountUSDC, 0, path, address(this), block.timestamp);

        // ETH to WBTC
        uint256 amountETH = address(this).balance - ethBalanceBefore;
        path[0] = WETH;
        path[1] = WBTC;
        uniswapRouter.swapExactETHForTokens{value: amountETH}(0, path, address(this), block.timestamp);

        // WBTC to USDC
        amountWBTC = IERC20(WBTC).balanceOf(address(this));
        path[0] = WBTC;
        path[1] = USDC;
        uniswapRouter.swapExactTokensForTokens(amountWBTC, 0, path, address(this), block.timestamp);

        // USDC to DAI
        amountUSDC = IERC20(USDC).balanceOf(address(this));
        path[0] = USDC;
        path[1] = DAI;
        uniswapRouter.swapExactTokensForTokens(amountUSDC, 0, path, address(this), block.timestamp);

        // DAI to AAVE
        amountDAI = IERC20(DAI).balanceOf(address(this));
        path[0] = DAI;
        path[1] = AAVE;
        uniswapRouter.swapExactTokensForTokens(amountDAI, 0, path, address(this), block.timestamp);

        ethBalanceBefore = address(this).balance;

        // AAVE to ETH
        uint256 amountAAVE = IERC20(AAVE).balanceOf(address(this));
        path[0] = AAVE;
        path[1] = WETH;
        uniswapRouter.swapExactTokensForETH(amountAAVE, 0, path, address(this), block.timestamp);

        // WETH to DAI
        amountETH = address(this).balance - ethBalanceBefore;
        path[0] = WETH;
        path[1] = DAI;
        uniswapRouter.swapExactETHForTokens{value: amountETH}(0, path, address(this), block.timestamp);

        // DAI to USDC
        amountDAI = IERC20(DAI).balanceOf(address(this));
        path[0] = DAI;
        path[1] = USDC;
        uniswapRouter.swapExactTokensForTokens(amountDAI, 0, path, address(this), block.timestamp);

        // USDC to ETH
        amountUSDC = IERC20(USDC).balanceOf(address(this));
        path[0] = USDC;
        path[1] = WETH;
        uniswapRouter.swapExactTokensForETH(amountUSDC, 0, path, address(this), block.timestamp);

        // ETH to DAI
        path[0] = WETH;
        path[1] = DAI;
        uniswapRouter.swapExactETHForTokens{value: address(this).balance - ethBalanceBefore}(
            0, path, address(this), block.timestamp
        );

        // DAI to WBTC
        amountDAI = IERC20(DAI).balanceOf(address(this));
        path[0] = DAI;
        path[1] = WBTC;
        uniswapRouter.swapExactTokensForTokens(amountDAI, 0, path, address(this), block.timestamp);

        require(IERC20(WBTC).balanceOf(address(this)) != 0);

        require(IERC20(WETH).balanceOf(address(this)) == 0);
        require(IERC20(AAVE).balanceOf(address(this)) == 0);
        require(IERC20(USDC).balanceOf(address(this)) == 0);
        require(IERC20(DAI).balanceOf(address(this)) == 0);
    }
}
