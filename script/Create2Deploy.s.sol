// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseScript, MyContract} from "./BaseScript.s.sol";

contract Create2Deploy is BaseScript {
    // try broadcasting to a fork twice
    function run() public {
        setUp();
        bytes memory initializationCode = type(MyContract).creationCode;
        bytes32 salt = bytes32(uint256(0));
        vm.broadcast(deployer);
        CREATE2_FACTORY.safeCreate2(salt, initializationCode);
    }
}
