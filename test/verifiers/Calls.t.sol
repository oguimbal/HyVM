// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./MyToken.sol";
import {Utils} from "../utils/Utils.sol";
import "./CallVerifiers.sol";

contract MyTokenTest is Test {
    MyToken myToken;
    address public hyvm;
    address owner;
    address ZERO_ADDRESS = address(0);
    address user = address(0x1231231231231231231231231231231231231231);
    uint256 balance = 100 * 1e18;

    //  =====   Set up  =====
    function setUp() public {
        owner = address(this);
        myToken = new MyToken();
        // send some tokens to me
        vm.prank(owner);
        myToken.mint(owner, balance);

        // set deploy VM & set verifier contract
        hyvm = HuffDeployer.deploy("HyVM");
    }

    // TODO test ownership... once an owner is defined, must not be able to change owner,
    // TODO once there is an owner, the owner must be able to change verifier
    // TODO once there is an owner, someone else cannot change the verifier
    // TODO write tests for all kind of calls (as time of writing, only CALL & STATICCALL are tested, but we must also test DELEGATECALL & CALLCODE)

    function setVerifier(IHyVMCallVerifier verifier) public {
        bytes memory code = Utils.setVerifierBytecode(hyvm, address(verifier));
        (bool success, ) = hyvm.delegatecall(code);
        assert(success);
    }

    function testTransfer() public {
        // allow all calls
        setVerifier(new VerifyAllCalls());
        (bool success, ) = performTransfer();

        assertEq(success, true);

        console.log("checking that user has received tokens");
        assertEq(myToken.balanceOf(user), balance / 2);
        assertEq(myToken.balanceOf(owner), balance / 2);
    }

    function testContractVerifierOK() public {
        setVerifier(new VerifyOnlyCallsTo(address(myToken)));
        (bool success, ) = performTransfer();

        assertEq(success, true);

        console.log("checking that user has received tokens");
        assertEq(myToken.balanceOf(user), balance / 2);
        assertEq(myToken.balanceOf(owner), balance / 2);
    }


    // function testContractVerifierKO() public {
    //     setVerifier(new VerifyOnlyCallsTo(address(this)));
    //     (bool success, ) = performTransfer();

    //     assertEq(success, false); // expecting revert

    //     // check that balances have failed to update
    //     assertEq(myToken.balanceOf(user), 0);
    //     assertEq(myToken.balanceOf(owner), balance);
    // }


    function testBalanceOfVerifierOK() public {
        setVerifier(new OnlyAllowExchengesWith(user));
        (bool success, ) = performTransfer();

        assertEq(success, true);

        console.log("checking that user has received tokens");
        assertEq(myToken.balanceOf(user), balance / 2);
        assertEq(myToken.balanceOf(owner), balance / 2);
    }


    // function testBalanceOfVerifierKO() public {
    //     setVerifier(new OnlyAllowExchengesWith(user));
    //     (bool success, ) = performTransfer();

    //     assertEq(success, false); // expecting revert

    //     // check that balances have failed to update
    //     assertEq(myToken.balanceOf(user), 0);
    //     assertEq(myToken.balanceOf(owner), balance);
    // }

    function performTransfer() public returns (bool success, bytes memory result) {

        // regenerate this using 👉 solc --optimize --bin test/calls/SendERC20.sol
        bytes
            memory bytecode = hex"608060405234801561001057600080fd5b506040516370a0823160e01b8152306004820152600090731234567890abcdef1234567890abcdef12345678906370a0823190602401602060405180830381865afa158015610063573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906100879190610139565b9050731234567890abcdef1234567890abcdef1234567863a9059cbb7312312312312312312312312312312312312312316100c3600285610152565b6040516001600160e01b031960e085901b1681526001600160a01b03909216600483015260248201526044016020604051808303816000875af115801561010e573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906101329190610174565b505061019d565b60006020828403121561014b57600080fd5b5051919050565b60008261016f57634e487b7160e01b600052601260045260246000fd5b500490565b60006020828403121561018657600080fd5b8151801515811461019657600080fd5b9392505050565b60bd806101ab6000396000f3fe6080604052348015600f57600080fd5b506004361060325760003560e01c8063d4b83992146037578063fc0c546a14606d575b600080fd5b605173123123123123123123123123123123123123123181565b6040516001600160a01b03909116815260200160405180910390f35b6051731234567890abcdef1234567890abcdef123456788156fea2646970667358221220aa090d14556401ee765966a7d0ee083f18232d32081f3f1a20c5a8dd4d0b2d1864736f6c634300080f0033";

        // just replace the dummy addresses by ours
        bytecode = Utils.replace(
            bytecode,
            0x1234567890AbcdEF1234567890aBcdef12345678,
            address(myToken)
        );
        bytecode = Utils.replace(
            bytecode,
            0x1231231231231231231231231231231231231231,
            user
        );
        console.log("Token & user: ");
        console.log(address(myToken));
        console.log(user);

        console.log("checking that user has 0 tokens");
        assertEq(myToken.balanceOf(user), 0);
        assertEq(myToken.balanceOf(owner), balance);

        // execute
        console.log(" => starting execution");
        return hyvm.delegatecall(bytecode);
    }
}
