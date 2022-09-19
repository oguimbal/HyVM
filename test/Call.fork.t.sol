// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./Utils.sol";
import "./CallVerifiers.sol";

import "./calls/IERC20.sol";

import "./calls/DoubleSwap_native.sol";
import "./calls/CallNvm.sol";

import "./calls/SupplyBorrowMorpho.sol";
import "./calls/DepositBorrowAave.sol";

import "./Utils.sol";
import "./Constants.sol";

import "./ILens.sol";

contract CallForkTests is Test {
    address nvm;
    address doubleSwapHuff;
    address owner;
    uint256 balance = 1000 * 1e6;
    DoubleSwap doubleSwap;
    CallNvm callNvm;
    bytes doubleswapNvmBytecode;
    bytes depositBorrowAaveNvmBytecode;
    bytes supplyBorrowMorphoNvmBytecode;
    SupplyBorrowMorpho supplyBorrowMorpho;
    DepositBorrowAave depositBorrowAave;

    ILendingPool lendingPool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    ILens lens = ILens(0x930f1b46e1D081Ec1524efD95752bE3eCe51EF67);

    //  =====   Set up  =====
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("eth"));
        owner = address(this);
        nvm = HuffDeployer.deploy("NVM");
        doubleSwapHuff = HuffDeployer.deploy("../test/calls/DoubleSwap");
        doubleSwap = new DoubleSwap();
        callNvm = new CallNvm();

        doubleswapNvmBytecode = getDoubleSwapBytecode();
        depositBorrowAaveNvmBytecode = getDepositBorrowAaveNvmBytecode();
        supplyBorrowMorphoNvmBytecode = getSupplyBorrowMorphoNvmBytecode();

        supplyBorrowMorpho = new SupplyBorrowMorpho();
        depositBorrowAave = new DepositBorrowAave();
    }

    receive() external payable {}

    function getDoubleSwapBytecode() public returns (bytes memory bytecode) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/DoubleSwap_nvm.sol | head -4 | tail -1)';
        return executeBashCommand(bashCommand);
    }

    function getDepositBorrowAaveNvmBytecode() public returns (bytes memory) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/DepositBorrowAave.sol | head -4 | tail -1 | cut -c 65-)';
        return executeBashCommand(bashCommand);
    }

    function getSupplyBorrowMorphoNvmBytecode() public returns (bytes memory) {
        string
            memory bashCommand = 'cast abi-encode "f(bytes)" $(solc --optimize --bin test/calls/SupplyBorrowMorpho.sol | tail -1 | cut -c 65-)';
        return executeBashCommand(bashCommand);
    }

    function executeBashCommand(string memory bashCommand)
        public
        returns (bytes memory bytecode)
    {
        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;
        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    // TODO write tests for all kind of calls (as time of writing, only CALL & STATICCALL are tested, but we must also test DELEGATECALL & CALLCODE)

    function testDoubleSwap_native_solidity() public {
        deal(USDC, address(doubleSwap), 100_000_000 * 10**6);
        doubleSwap.doubleSwap();
    }

    function testDoubleSwap_nvm_solidity() public {
        deal(USDC, address(callNvm), 100_000_000 * 10**6);
        callNvm.callNvm(nvm, doubleswapNvmBytecode);
    }

    function testDoubleSwap_native_huff() public {
        deal(USDC, address(this), 100_000_000 * 10**6);
        (bool success, ) = doubleSwapHuff.delegatecall(new bytes(0));
        assertEq(success, true);
    }

    function testDoubleSwap_nvm_huff() public {
        deal(USDC, address(callNvm), 100_000_000 * 10**6);
        callNvm.callNvm(nvm, doubleSwapHuff.code);
    }

    function testDepositBorrowAaveNvm() public {
        deal(USDC, address(callNvm), 100_000_000 * 10**6);
        (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        // replace "depositBorrowAave" selector and bypass calldata size check
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                depositBorrowAaveNvmBytecode,
                hex"d280ed95"
            );
        callNvm.callNvm(nvm, finalBytecode);
        (totalCollateralETH,  totalDebtETH,  availableBorrowsETH,  currentLiquidationThreshold,  ltv, ) = lendingPool.getUserAccountData(address(callNvm));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0 , true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }

    function testDepositBorrowAaveNative() public {
        deal(USDC, address(depositBorrowAave), 100_000_000 * 10**6);
        (uint256 totalCollateralETH, uint256 totalDebtETH, uint256 availableBorrowsETH, uint256 currentLiquidationThreshold, uint256 ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH, 0);
        assertEq(totalDebtETH, 0);
        assertEq(currentLiquidationThreshold, 0);
        assertEq(ltv, 0);
        depositBorrowAave.depositBorrowAave();
        (totalCollateralETH,  totalDebtETH,  availableBorrowsETH,  currentLiquidationThreshold, ltv,) = lendingPool.getUserAccountData(address(depositBorrowAave));
        assertEq(totalCollateralETH > 0, true);
        assertEq(totalDebtETH > 0 , true);
        assertEq(currentLiquidationThreshold > 0, true);
        assertEq(ltv > 0, true);
    }

    function testSupplyBorrowMorphoNvm() public {
        deal(DAI, address(callNvm), 100_000_000 * 10**18);
        // replace "supplyBorrowMorpho" selector and bypass calldata size check
        address[] memory path = new address[](2);
        path[0] = USDC;
        path[1] = DAI;
        (,,uint256 totalBalanceDAI) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callNvm));
        (,,uint256 totalBalanceUSDC) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callNvm));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        bytes memory finalBytecode = Utils
            .replaceSelectorBypassCalldataSizeCheck(
                supplyBorrowMorphoNvmBytecode,
                hex"b9ab7b77"
            );
        callNvm.callNvm(nvm, finalBytecode);
        (,,totalBalanceDAI) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callNvm));
        (,,totalBalanceUSDC) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callNvm));
        assertEq(totalBalanceDAI == 9999999, true);
        assertEq(totalBalanceUSDC >  99 * 10**18, true);
    }

    function testSupplyBorrowMorphoNative() public {
        deal(DAI, address(supplyBorrowMorpho), 100_000_000 * 10**18);
        (,,uint256 totalBalanceDAI) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(callNvm));
        (,,uint256 totalBalanceUSDC) = lens.getCurrentSupplyBalanceInOf(cDAI, address(callNvm));
        assertEq(totalBalanceDAI == 0, true);
        assertEq(totalBalanceUSDC == 0, true);
        supplyBorrowMorpho.supplyBorrowMorpho();
        (,,totalBalanceDAI) = lens.getCurrentBorrowBalanceInOf(cUSDC, address(supplyBorrowMorpho));
        (,,totalBalanceUSDC) = lens.getCurrentSupplyBalanceInOf(cDAI, address(supplyBorrowMorpho));
        assertEq(totalBalanceDAI == 9999999, true);
        assertEq(totalBalanceUSDC >  99 * 10**18, true);
    }
}
