// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;

    function setUp() public {
        counter = new Counter(10); // Initialize counter with 0
    }

    function testIncrement() public {
        counter.increment();
        assertEq(counter.getCount(), 11);
        emit log_named_int("Count after increment", counter.getCount());
    }

    function testDecrement() public {
        counter.decrement();
        assertEq(counter.getCount(), 9);
        emit log_named_int("Count after decerement", counter.getCount());
    }

    function testGetCount() public {
        assertEq(counter.getCount(), 10);
        emit log_named_int("Current count", counter.getCount());
    }
}
