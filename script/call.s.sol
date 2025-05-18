// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Script, console} from "forge-std/Script.sol";
import "../src/BallisticPay.sol";

contract PrintLatestPrice is Script {
    function run() external view {
        // Pass your deployed BallisticPay contract address directly here:
        BallisticPay ballisticPay = BallisticPay(0x257c9830C0133bE5D5e2B1d610865F7727a6E929);

        (uint80 roundID, int price) = ballisticPay.getLatestPrice();

        console.log("Round ID:", roundID);
        console.log("Price:", price);
    }
}

