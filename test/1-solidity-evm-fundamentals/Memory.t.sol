// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

contract Memory is Test {
    struct PackedStruct {
        uint64 a;
        uint64 b;
        uint64 c;
    }

    struct NestedStruct {
        PackedStruct a;
        uint256[2] b;
    }

    PackedStruct packed;

    function setUp() public {
        packed = PackedStruct({a: 1, b: 2, c: 3});
    }

    /**
     * @notice
     */
    function testPackedStruct() public {
        uint256 value;

        PackedStruct memory packedMemory = packed;

        assembly {
            value := sload(packed.slot)
        }
        emit log_named_bytes("Abi-encoded PackedStruct raw from storage", abi.encode(value));
        emit log_named_bytes("Abi-encoded PackedStruct from memory", abi.encode(packedMemory));
    }

    function testArrays() public {
        uint256[] memory a = new uint256[](2);
        a[0] = 1;
        a[1] = 2;
        uint256[2] memory b = [uint256(1), uint256(2)];
        emit log_named_bytes("Abi-encoded uint256[] from memory", abi.encode(a));
        emit log_named_bytes("Abi-encoded uint256[2] from memory", abi.encode(b));
    }

    function testAbiEncodeNestedStruct() public {
        uint256[2] memory b = [uint256(8), uint256(9)];
        NestedStruct memory nested = NestedStruct({a: packed, b: b});
        emit log_named_bytes("Abi-encoded NestedStruct from memory", abi.encode(nested));
    }
}
