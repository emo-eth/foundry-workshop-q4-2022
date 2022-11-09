// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseScript, MyContract} from "./BaseScript.s.sol";

contract Deploying is BaseScript {
    function run() public {
        setUp();
        vm.broadcast(deployer);
        new MyContract();
    }
}
