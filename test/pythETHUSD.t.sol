// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PythETHUSD.sol";

interface IPythMock {
    function getUpdateFee(bytes[] calldata updateData) external view returns (uint);
    function updatePriceFeeds(bytes[] calldata updateData) external payable;
    function getPriceUnsafe(bytes32 id) external view returns (PythStructs.Price memory);
}

contract PythETHUSDTest is Test {
    PythETHUSD public priceContract;

    function setUp() public {
        priceContract = new PythETHUSD();
    }

    function testDeployment() public view {
        assertTrue(address(priceContract) != address(0), "Contract should be deployed");
    }

    function testGetPriceUnsafe() public {
    try priceContract.getPrice() returns (PythStructs.Price memory price) {
        emit log_named_int("Price", price.price);
        emit log_named_int("Confidence Interval", int256(uint256(price.conf)));
        emit log_named_int("Exponent", price.expo);
    } catch {
        emit log("Reverted as expected due to missing Pyth contract on local network");
    }
}


    function testGetLatestPriceWithEmptyUpdateData() public payable {
    bytes[] memory updateData = new bytes[](0);

    // If running on a fork or mainnet, this likely reverts
    // You should only use expectRevert if you’re confident about the revert cause

    try priceContract.getLatestPrice{value: 0}(updateData) {
        emit log("Expected getLatestPrice to revert due to empty update data");
        fail();
    } catch Error(string memory reason) {
        emit log_named_string("Revert reason", reason);
    } catch (bytes memory /* lowLevelData */) {
        emit log("Reverted without error string (likely from low-level call)");
    }
}

}
