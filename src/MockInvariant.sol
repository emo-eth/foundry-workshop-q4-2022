// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MockInvariant {
    uint256 public previousValue;
    uint256 public value = 1;
    bool public plsNoSetFalse = true;
    bool public excludedArtifactFlipped = false;

    error NewValueMustBeGreater();

    function increaseValue(uint256 _value) public {
        uint256 prevVal = value;
        if (_value <= prevVal && msg.sender != address(bytes20("malicious actooor"))) {
            revert NewValueMustBeGreater();
        }
        previousValue = prevVal;
        value = _value;
    }

    function noCallMePls() public {
        plsNoSetFalse = false;
    }
}
