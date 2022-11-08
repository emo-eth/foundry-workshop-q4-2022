// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";

contract Storage is Test {
    struct PackedStruct {
        uint64 a;
        uint64 b;
        uint64 c;
    }

    struct NotPackedStruct {
        uint256 a;
        uint256 b;
    }

    uint256 public a;
    uint256 public b;
    uint256[] public c;
    uint256[][] public d;
    mapping(uint256 => uint256[]) public e;
    uint256[2] public f;

    PackedStruct packed;
    NotPackedStruct notPacked;

    /**
     * @dev populate storage variables with values.
     */
    function setUp() public {
        a = 1;
        b = 2;
        c.push(3);
        c.push(4);
        d.push([5, 6]);
        d.push([7, 8]);
        e[9] = [10];
        e[11] = [12];
        f = [13, 14];
        packed = PackedStruct({a: 1, b: 2, c: 3});
        notPacked = NotPackedStruct({a: 1, b: 2});
    }

    /**
     * @notice Explicitly log storage layout of the contract.
     *         What slot do storage variables start at? Why?
     */
    function testSlotsAndValues() public {
        uint256 slot;
        uint256 value;

        assembly {
            slot := a.slot
        }
        emit log_named_uint('Storage slot for "a"', slot);
        emit log_named_uint('Value stored at "a.slot"', a);

        assembly {
            slot := b.slot
        }
        emit log_named_uint('Storage slot for "b"', slot);
        emit log_named_uint('Value stored at "b.slot"', b);
        uint256[] storage cRef = c;
        assembly {
            slot := cRef.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "c"', slot);
        assembly {}
        emit log_named_uint('Value stored at "c.slot"', value);

        uint256[][] storage dRef = d;
        assembly {
            slot := dRef.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "d"', slot);
        emit log_named_uint('Value stored at "d.slot"', value);
        uint256[] storage dZeroRef = d[0];
        assembly {
            slot := dZeroRef.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "d[0]"', slot);
        emit log_named_uint('Value stored at "d[0].slot"', value);
        uint256[] storage dOneRef = d[1];
        assembly {
            slot := dOneRef.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "d[1]"', slot);
        emit log_named_uint('Value stored at "d[1].slot"', value);

        assembly {
            slot := e.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "e"', slot);
        emit log_named_uint('Value stored at "e.slot"', value);
        uint256[] storage eNineRef = e[9];
        assembly {
            slot := eNineRef.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "e[9]"', slot);
        emit log_named_uint('Value stored at "e[9].slot"', value);

        assembly {
            slot := f.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "f"', slot);
        emit log_named_uint('Value stored at "f.slot"', value);
        assembly {
            slot := add(1, slot)
            value := sload(slot)
        }
        emit log_named_uint("Storage slot f.slot + 1", slot);
        emit log_named_uint("Value stored at f.slot + 1", value);

        assembly {
            slot := packed.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "packed"', slot);
        emit log_named_bytes32('Value stored at "packed.slot"', bytes32(value));

        assembly {
            slot := notPacked.slot
            value := sload(slot)
        }
        emit log_named_uint('Storage slot for "notPacked"', slot);
        emit log_named_uint('Value stored at "notPacked.slot"', value);
    }
}
