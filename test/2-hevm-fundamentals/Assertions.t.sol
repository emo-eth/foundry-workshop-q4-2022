// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

contract Assertions is Test {
    event log_named_array(string key, bytes32[] val);

    /**
     * @notice don't use this in practice!! use vm.expectRevert instead - that way you can be sure tests fail for the reasons you expect
     */
    function testFail() public {
        revert();
    }

    function _logFailureSlots() internal {
        emit log_named_uint("Current value of HEVM slot", uint256(vm.load(HEVM_ADDRESS, bytes32("failed"))));
        bytes32 existingFailedSlot = vm.load(address(this), bytes32(uint256(7)));
        emit log_named_bytes32("Current value of _failed slot", existingFailedSlot);
    }

    function _resetFailureSlots() internal {
        emit log_string("Overwriting the failure slots with 0.");
        vm.store(HEVM_ADDRESS, bytes32("failed"), bytes32(0));
        // failed slot is packed with another bool variable
        bytes32 existingFailedSlot = vm.load(address(this), bytes32(uint256(7)));
        vm.store(address(this), bytes32(uint256(7)), bytes32(uint256(existingFailedSlot) - 0x0100));
    }

    function test_FailureSlot() public {
        emit log_named_address("HEVM Address", HEVM_ADDRESS);
        emit log_named_bytes32("HEVM Failure Slot - the string 'failed' as bytes32", bytes32("failed"));
        emit log_named_uint("Current value of HEVM slot", uint256(vm.load(HEVM_ADDRESS, bytes32("failed"))));
        emit log_string("Failing an assertion: assertFalse(true)");
        vm.record();
        assertFalse(true);
        (bytes32[] memory reads, bytes32[] memory writes) = vm.accesses(address(this));
        emit log_named_array("Reads", reads);
        emit log_named_array("Writes", writes);
        // assertEq(vm.load(address(this), reads[1]), writes[0]);
        _logFailureSlots();
        emit log_string("Overwriting the failure slots with 0.");
        vm.store(HEVM_ADDRESS, bytes32("failed"), bytes32(0));
        // failed slot is packed with another bool variable
        bytes32 existingFailedSlot = vm.load(address(this), bytes32(uint256(7)));
        vm.store(address(this), reads[1], bytes32(uint256(existingFailedSlot) - 0x0100));
        _logFailureSlots();
        emit log_named_uint("failed() method", uint256(this.failed() ? 1 : 0));
    }

    function testPassAssertWithRollback() public {
        uint256 id = vm.snapshot();
        assertTrue(false);
        _logFailureSlots();
        emit log_string("Reverting to snapshot");
        vm.revertTo(id);
        _logFailureSlots();
    }

    function testFailAssertWithForks() public {
        uint256 id = vm.createSelectFork(stdChains.Mainnet.rpcUrl);
        assertTrue(false);
        _logFailureSlots();
        emit log_string("Changing forks");
        uint256 goerli = vm.createSelectFork(stdChains.Goerli.rpcUrl);
        _logFailureSlots();
        assertTrue(true);
    }
}
