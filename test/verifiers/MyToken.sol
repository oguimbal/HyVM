// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    address public owner;

    constructor() ERC20("My Token", "MTKN") {
        owner = msg.sender;
    }

    function mint(address account, uint256 amount) public {
        require(msg.sender == owner, "Only Owner can mint");
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        require(msg.sender == owner, "Only Owner can burn");
        _burn(account, amount);
    }
}
