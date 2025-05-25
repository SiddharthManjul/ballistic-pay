// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Script, console} from "forge-std/Script.sol";
import "../src/BallisticPay.sol";

contract PrintLatestPrice is Script {
    function run() external view {
        // Pass your deployed BallisticPay contract address directly here:
        BallisticPay ballisticPay = BallisticPay(0xB06782f2dFdBcf3b324034BB6C5743bb3A6e92B6);

        (uint80 btcUsdRoundID, int btcUsdPrice) = ballisticPay.getLatestBtcUsdPrice();
        (uint80 ethUsdRoundID, int ethUsdPrice) = ballisticPay.getLatestEthUsdPrice();

        console.log("BTC/USD Round ID:", btcUsdRoundID);
        console.log("BTC/USD Price:", btcUsdPrice);
        console.log("ETH/USD Round ID:", ethUsdRoundID);
        console.log("ETH/USD Price:", ethUsdPrice);
    }
}

