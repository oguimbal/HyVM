// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "./Utils.sol";
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
        // PositionRouter
        IGMXPositionRouter positionRouter = IGMXPositionRouter(
            0x3D6bA331e3D9702C5e8A8d254e5d8a285F223aba
        );
        // Admin of the Position Router
        address positionRouterAdmin = address(
            0x5F799f365Fa8A2B60ac0429C48B153cA5a6f0Cf8
        );
        // Deal USDC and ETH to contract that will open a long position
        deal(USDC, address(gmxLong), 1000000000 * 10**6);
        deal(address(gmxLong), 1000000000 * 10**18);
        // opens long position
        gmxLong.gmxLong();
        // Keeper that will execute the requests
        address keeper = address(123);
        // balance before for the keeper
        uint256 balanceBefore = keeper.balance;
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
        positionRouter.executeIncreasePosition(key, payable(keeper));
        // Balance of the keeper after
        uint256 balanceAfter = keeper.balance;
        // Verify keeper received fees
        assertEq(balanceAfter > balanceBefore, true);
    }

    function testGMXLongHyvm() public {
        // PositionRouter
        IGMXPositionRouter positionRouter = IGMXPositionRouter(
            0x3D6bA331e3D9702C5e8A8d254e5d8a285F223aba
        );
        // Admin of the Position Router
        address positionRouterAdmin = address(
            0x5F799f365Fa8A2B60ac0429C48B153cA5a6f0Cf8
        );
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
        // balance before for the keeper
        uint256 balanceBefore = keeper.balance;
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
        positionRouter.executeIncreasePosition(key, payable(keeper));
        // Balance of the keeper after
        uint256 balanceAfter = keeper.balance;
        // Verify keeper received fees
        assertEq(balanceAfter > balanceBefore, true);
    }
}
