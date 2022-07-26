// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "./IERC20.sol";

contract SimpleTransfer {
    IERC20 public constant token = IERC20(0x1234567890AbcdEF1234567890aBcdef12345678);
    address public constant target = address(0x1231231231231231231231231231231231231231);
    constructor() {
        uint256 amt = token.balanceOf(address(this));
        token.transfer(target, amt / 2);
    }
}
