// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {MockInvariant} from "../src/MockInvariant.sol";

contract IgnoreMe {}

contract MockInvariantTest is Test {
    struct ArtifactSelector {
        string optionalPathColonPlusContractName;
        bytes4[] selectors;
    }

    MockInvariant test;

    address[] _excludeContracts;
    address[] _targetContracts;

    function setUp() public {
        test = new MockInvariant();
        _targetContracts.push(address(test));

        IgnoreMe ignore = new IgnoreMe();
        _excludeContracts.push(address(ignore));
    }

    function invariantIncreasing() public {
        assertGt(test.value(), test.previousValue());
    }

    function invariantFragile() public {
        assertTrue(test.plsNoSetFalse());
    }

    function invariantExcludeArtifacts() public {
        assertFalse(test.excludedArtifactFlipped());
    }

    function targetArtifactSelectors() public pure returns (ArtifactSelector[] memory) {
        ArtifactSelector[] memory artifactSelectors = new ArtifactSelector[](1);
        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = bytes4(keccak256("increaseValue(uint256)"));
        selectors[1] = bytes4(keccak256("previousValue()"));
        selectors[2] = bytes4(keccak256("value()"));
        artifactSelectors[0] = ArtifactSelector({
            optionalPathColonPlusContractName: "src/MockInvariant.sol:MockInvariant",
            selectors: selectors
        });

        return artifactSelectors;
    }

    function excludeArtifacts() public pure returns (string[] memory) {
        string[] memory artifacts = new string[](1);
        artifacts[0] = "test/MockInvariant.t.sol:IgnoreMe";
        return artifacts;
    }

    function targetArtifacts() public pure returns (string[] memory) {
        string[] memory artifacts = new string[](1);
        artifacts[0] = "src/MockInvariant.sol:MockInvariant";
        return artifacts;
    }

    function targetSenders() public pure returns (address[] memory) {
        address[] memory senders = new address[](1);
        senders[0] = address(bytes20("malicious actooor"));
        return senders;
    }

    function excludeSenders() public pure returns (address[] memory) {
        address[] memory senders = new address[](1);
        senders[0] = address(bytes20("good actooor"));
        return senders;
    }

    function targetContracts() public view returns (address[] memory) {
        return _targetContracts;
    }

    function excludeContracts() public view returns (address[] memory) {
        return _excludeContracts;
    }
}
