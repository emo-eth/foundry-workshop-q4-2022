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
        called = true;
        assembly {
            pop(div(1, 0))
        }
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

    function testTryCatch1() public {
        try helper.revertsWithString() returns (bool called) {
            // won't reach here
        } catch (bytes memory reason) {
            // bytes4(keccak256("Error(string)")) == 0x08c379a0
            assertEq(reason, bytes.concat(hex"08c379a0", abi.encode("revert")), "Error(string) bytes incorrect");
        }

        try helper.revertsWithString() returns (bool called) {
            // won't reach here
        } catch Error(string memory reason) {
            assertEq(reason, "revert", "String reason incorrect");
        }

        try helper.revertsWithCustomError() returns (bool called) {}
        catch (bytes memory reason) {
            assertEq(
                reason, abi.encodeWithSelector(Helper.CustomError.selector, "revert"), "Bytes revert reason incorrrect"
            );
        }

        try helper.revertsWithPanic() returns (bool called) {}
        catch Panic(uint256 panic) {
            assertEq(panic, 0x11, "Panic code not correct");
        }
    }

    function testCall() public {
        (bool success, bytes memory data) =
            address(helper).call(abi.encodeWithSelector(Helper.revertsWithCustomError.selector));
        assertFalse(success, "Should not have succeeded");
        assertEq(data, abi.encodeWithSelector(Helper.CustomError.selector, "revert"), "Custom error bytes incorrect");

        (success, data) = address(helper).call(abi.encodeWithSelector(Helper.doesNotRevert.selector));
        assertTrue(success, "Call should have succeeded");
        assertTrue(abi.decode(data, (bool)), "Call should have returned true");
    }
}
