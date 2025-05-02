// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    int private count;

    constructor(int _count) {
        count = _count;
    }

    function increment() public {
        count++;
    }

    function decrement() public {
        count--;
    }

    function getCount() public view returns (int) {
        return count;
    }
}
