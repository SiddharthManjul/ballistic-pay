// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/PythETHUSD.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract PythETHUSDDeployment is Script {
    function run() external {
        // Load deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the contract
        PythETHUSD contractInstance = new PythETHUSD();
        console.log("PythETHUSD deployed at:", address(contractInstance));

        // Optional: Interact with it using dummy data
        // (In practice, you should use real priceUpdateData)
        bytes[] memory updateData = new bytes[](0);

        // Get fee required to update (won’t work unless Pyth is live and updateData is valid)
        uint256 fee = contractInstance.pyth().getUpdateFee(updateData);
        console.log("Update fee (wei):", fee);

        // Try updating (only works with real update data)
        try contractInstance.getLatestPrice{value: fee}(updateData) returns (PythStructs.Price memory price) {
            console.log("Fetched Price:", price.price);
            console.log("Confidence Interval:", price.conf);
        } catch {
            console.log("Price update failed (probably due to missing or invalid update data)");
        }

        vm.stopBroadcast();
    }
}
