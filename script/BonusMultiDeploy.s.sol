// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {BaseScript, MyContract} from "./BaseScript.s.sol";

// install PR #2541 with `foundryup -P 2541`
// https://github.com/foundry-rs/foundry/pull/2541
// then fork each chain with separate instances of anvil
// see `lib/bash-utils/multi-anvil.sh` for a script that does this automatically
contract BonusMultiDeploy is BaseScript {
    function run() public {
        Chain[] memory deployChains = new Chain[](3);
        deployChains[0] = stdChains.Mainnet;
        deployChains[1] = stdChains.Goerli;
        deployChains[2] = stdChains.Sepolia;
        for (uint256 i; i < deployChains.length; i++) {
            Chain memory chain = deployChains[i];
            vm.createSelectFork(chain.rpcUrl);
            vm.broadcast(deployer);
            new MyContract();
        }
    }
}
