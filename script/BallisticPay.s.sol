// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {BallisticPay} from "../src/BallisticPay.sol";

contract DeployBallisticPay is Script {
    function run() external {
        vm.startBroadcast();
        BallisticPay ballisticPay = new BallisticPay();
        console.log("BallisticPay deployed to:", address(ballisticPay));
        vm.stopBroadcast();
    }
}