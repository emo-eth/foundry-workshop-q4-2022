// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

contract Helper {
    bool public called;

    error CustomError(string message);

    function doesNotRevert() public returns (bool) {
        called = true;
        return called;
    }

    function revertsWithString() public returns (bool) {
        called = true;
        revert("revert");
        return called;
    }

    function revertsWithCustomError() public returns (bool) {
        called = true;
        revert CustomError("revert");
        return called;
    }

    function revertsWithoutMessage() public returns (bool) {
        called = true;
        revert();
        return called;
    }

    function revertsWithPanic() public returns (bool) {
        uint256 x = 0;
        called = true;
        uint256 value = 1 / x;
        return called;
    }

    function readRevert() public view returns (bool) {
        revert();
        return called;
    }

    function reset() public {
        called = false;
    }
}

contract CallsAndReverts is Test {
    Helper helper;

    function setUp() public {
        helper = new Helper();
    }

    /**
     * @notice
     */
    function testNormalCall() public {
        vm.expectRevert("revert");
        helper.revertsWithString();
    }

    function testTryCatch() public {
        try helper.revertsWithString() returns (bool called) {}
        catch (bytes memory reason) {
            // bytes4(keccak256("Error(string)")) == 0x08c379a0
            emit log_named_bytes("Error(string)", reason);
            assertEq(reason, bytes.concat(hex"08c379a0", abi.encode("revert")), "Error(string) bytes incorrect");
        }

        try helper.revertsWithString() returns (bool called) {
            // won't reach here
        } catch Error(string memory reason) {
            assertEq(reason, "revert", "String reason incorrect");
        }

        try helper.revertsWithPanic() returns (bool called) {}
        catch (bytes memory reason) {
            emit log_named_bytes("Panic(uint256)", reason);
            assertEq(reason, bytes.concat(hex"4e487b71", bytes32(uint256(18))), "Error(string) bytes incorrect");
        }

        try helper.revertsWithPanic() returns (bool called) {}
        catch Panic(uint256 panic) {
            assertEq(panic, 18, "Panic code not correct");
        }

        try helper.revertsWithCustomError() returns (bool called) {}
        catch (bytes memory reason) {
            assertEq(
                reason, abi.encodeWithSelector(Helper.CustomError.selector, "revert"), "Bytes revert reason incorrrect"
            );
        }

        assertFalse(helper.called(), "Called should be false");
    }

    function testCall() public {
        (bool success, bytes memory data) =
            address(helper).call(abi.encodeWithSelector(Helper.revertsWithCustomError.selector));
        assertFalse(success, "Should not have succeeded");
        assertEq(data, abi.encodeWithSelector(Helper.CustomError.selector, "revert"), "Custom error bytes incorrect");

        assertFalse(helper.called(), "Called should be false");

        (success, data) = address(helper).call(abi.encodeWithSelector(Helper.doesNotRevert.selector));
        assertTrue(success, "Call should have succeeded");
        assertTrue(abi.decode(data, (bool)), "Call should have returned true");

        (success, data) = address(helper).staticcall(abi.encodeWithSelector(Helper.readRevert.selector));
        assertFalse(success, "Should not have succeeded");
        assertEq(data, "", "Should have returned empty bytes");
    }

    function testCallWithExpectRevert() public {
        vm.expectRevert();
        (bool success,) = address(helper).call(abi.encodeWithSelector(Helper.revertsWithCustomError.selector));
        assertTrue(success, "Success should be true here");
    }
}
