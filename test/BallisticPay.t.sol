// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import {BallisticPay} from "../src/BallisticPay.sol";
import {MockV3Aggregator} from "@chainlink/contracts/v0.8/tests/MockV3Aggregator.sol";

contract BallisticPayTest is Test {
    uint8 public _decimals = 8;
    int256 public _initialAnswer = 10**18;

    BallisticPay public ballisticPay;
    MockV3Aggregator public priceFeed;

    function setUp() public {
        priceFeed = new MockV3Aggregator(_decimals, _initialAnswer);
        ballisticPay = new BallisticPay(address(priceFeed));
    }

    function testgetLatestPrice() public {
        (uint80 roundID, int256 price) = ballisticPay.getLatestPrice();

        assertEq(price, _initialAnswer);
        assertEq(roundID, 1);
    }
}