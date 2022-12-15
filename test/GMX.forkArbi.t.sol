// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import {Utils} from "./utils/Utils.sol";
import "./calls/CallHyvm.sol";
import "./calls/GMXLong.sol";
import "./calls/IGMX.sol";
import "./ConstantsArbitrum.sol";

contract GMXTest is Test {
    address hyvm;
    address doubleSwapHuff;
    address owner;
    uint256 balance = 1000 * 1e6;
    CallHyvm callHyvm;
    GMXLong gmxLong;
    bytes gmxLongHyvmBytecode;
    // PositionRouter
    IGMXPositionRouter positionRouter = IGMXPositionRouter(
            0xb87a436B93fFE9D75c5cFA7bAcFff96430b09868
        );
    // Admin of the Position Router
    address positionRouterAdmin = address(
        0x5F799f365Fa8A2B60ac0429C48B153cA5a6f0Cf8
    );

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("arbi"));
        owner = address(this);
        hyvm = HuffDeployer.deploy("HyVM");
        callHyvm = new CallHyvm();
        gmxLong = new GMXLong();
        gmxLongHyvmBytecode = type(GMXLong).runtimeCode;
    }

    receive() external payable {}

    function testGMXLongNative() public {
        // Deal USDC and ETH to contract that will open a long position
        deal(USDC, address(gmxLong), 1000000000 * 10**6);
        deal(address(gmxLong), 1000000000 * 10**18);
        // opens long position
        gmxLong.gmxLong();
        // Keeper that will execute the requests
        address keeper = address(123);
        // Set keeper address as a keeper for the positionRouter
        // Only admin fuction
        changePrank(positionRouterAdmin);
        positionRouter.setPositionKeeper(keeper, true);
        // Execute transaction
        // The transaction is identified by a requestKey
        changePrank(keeper);
        bytes32 key = positionRouter.getRequestKey(
            address(gmxLong),
            uint256(1)
        );
        bool exec = positionRouter.executeIncreasePosition(key, payable(keeper));
        // verify that the request was executed
        assertEq(exec, true);
    }

    function testGMXLongHyvm() public {
        // Deal USDC and ETH to contract that will open a long position
        deal(USDC, address(callHyvm), 1000000000 * 10**6);
        deal(address(callHyvm), 1000000000 * 10**18);
        // replace "gmxLong" selector and bypass calldata size check
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                gmxLongHyvmBytecode,
                hex"9507c78f"
            );
        // CallHyvm
        callHyvm.callHyvm(hyvm, finalBytecode);
        // Keeper that will execute the requests
        address keeper = address(123);
        // Set keeper address as a keeper for the positionRouter
        // Only admin fuction
        changePrank(positionRouterAdmin);
        positionRouter.setPositionKeeper(keeper, true);
        // Execute transaction
        // The transaction is identified by a requestKey
        changePrank(keeper);
        bytes32 key = positionRouter.getRequestKey(
            address(callHyvm),
            uint256(1)
        );
        bool exec = positionRouter.executeIncreasePosition(key, payable(keeper));
        // verify that the request was executed
        assertEq(exec, true);
    }
}
