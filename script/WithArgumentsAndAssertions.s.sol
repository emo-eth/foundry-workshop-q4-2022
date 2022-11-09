// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseScript} from "./BaseScript.s.sol";

contract WithArgumentsAndAssertions is BaseScript {
    function run(uint256 amount, address recipient) public {
        // this won't work on a real fork, naturally
        vm.deal(deployer, amount);
        vm.broadcast(deployer);
        payable(recipient).transfer(amount);
        // simulation will fail, making the script unable to be broadcast (unless you explicitly skip simulation)
        require(recipient.balance > 10 ether, "balance is not greater than 10 ether");
    }
}
