// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";

contract Looper {
    address hyvm;
    bytes byteCode;

    //  =====   Set up  =====
    constructor(address _hyvm, bytes memory _byteCode) {
        hyvm = _hyvm;
        byteCode = _byteCode;
    }

    function loop(uint256 i) public returns (uint256){
        uint256 j = i+1;

        bytes memory fullByteCode = abi.encodePacked(byteCode, abi.encode(address(this)), j);

        (bool success, ) = hyvm.call(fullByteCode);
        require(success, 'Failed to call HyVM');

        return j;
    }
}