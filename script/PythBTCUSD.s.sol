// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/Script.sol";
import "../src/PythBTCUSD.sol";

contract DeployPythBTCUSD is Script {
    address constant PYTH_ADDRESS = payable(0xA2aa501b19aff244D90cc15a4Cf739D2725B5729);

    function run() public {
        vm.startBroadcast();
        PythBTCUSD priceFeed = new PythBTCUSD(PYTH_ADDRESS);
        console.log("PythBTCUSD deployed at:", address(priceFeed));
        vm.stopBroadcast();
    }
}