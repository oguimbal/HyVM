// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

contract LoopedCall {
    constructor(ILooper _looper, uint256 i) {
        // Loop between the Looper contract and the HyVM, while i < 316
        // 
        // When i >= 316, running `forge test --match-test testLooper -vvvvv` command
        // returns this stack overflow error output:
        //
        //     thread '<unknown>' has overflowed its stack
        //     fatal runtime error: stack overflow
        //     Abandon (core dumped)
        if(i < 316){
            uint256 j = _looper.loop(i);

            require(j == i+1, "Wrong returned datas");
        }
    }

    function bytesToUint256(bytes memory data)
        internal pure
        returns (uint256)
    {
        require(data.length >= 32, "slicing out of range");
        uint256 x;
        assembly {
            x := mload(add(data, add(0x20, 0x00)))
        }
        return x;
    }
}

interface ILooper{
    function loop(uint256) external returns (uint256);
}