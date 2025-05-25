// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract BallisticPay {
    AggregatorV3Interface internal BTCUSDFeed;
    AggregatorV3Interface internal ETHUSDFeed;

    constructor() {
        BTCUSDFeed = AggregatorV3Interface(0x2Cd9D7E85494F68F5aF08EF96d6FD5e8F71B4d31);
        ETHUSDFeed = AggregatorV3Interface(0x0c76859E85727683Eeba0C70Bc2e0F5781337818);
    }

    function getLatestBtcUsdPrice() public view returns (uint80 roundID, int price) {
        (roundID, price ,,,) = BTCUSDFeed.latestRoundData();
        return (roundID, price);
    }

    function getLatestEthUsdPrice() public view returns (uint80 roundID, int price) {
        (roundID, price ,,,) = ETHUSDFeed.latestRoundData();
        return (roundID, price);
    }
}