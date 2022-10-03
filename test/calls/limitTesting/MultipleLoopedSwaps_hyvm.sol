// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;
import "../IUniswapV2Router01.sol";
import "../IERC20.sol";

contract MultipleSwap {
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IUniswapV2Router01 private constant uniswapRouter = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    
    constructor() {
        uint256 balance = IERC20(USDC).balanceOf(address(this));
        require(balance >= 0, 'Null USDC balance');
        IERC20(USDC).approve(address(uniswapRouter), type(uint256).max);
        IERC20(DAI).approve(address(uniswapRouter), type(uint256).max);

        address[] memory path = new address[](2);

        for(uint256 i; i < 500_000_000_000;){
            uint256 ethBalanceBefore = address(this).balance;

            // USDC to ETH
            uint256 amountUSDC = IERC20(USDC).balanceOf(address(this));
            path[0] = USDC;
            path[1] = WETH;
            uniswapRouter.swapExactTokensForETH(amountUSDC, 0, path, address(this), block.timestamp);

            // ETH to DAI
            path[0] = WETH;
            path[1] = DAI;
            uniswapRouter.swapExactETHForTokens{value: address(this).balance - ethBalanceBefore}(0, path, address(this), block.timestamp);

            // DAI to USDC
            uint256 amountDAI = IERC20(DAI).balanceOf(address(this));
            path[0] = DAI;
            path[1] = USDC;
            uniswapRouter.swapExactTokensForTokens(amountDAI, 0, path, address(this), block.timestamp);

            require(IERC20(USDC).balanceOf(address(this)) < amountUSDC);
            require(IERC20(WETH).balanceOf(address(this)) == 0);
            require(IERC20(DAI).balanceOf(address(this)) == 0);

            unchecked{
                ++i;
            }
        }
    }
}