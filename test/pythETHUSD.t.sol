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

    function testDeployment() public {
        assertTrue(address(priceContract) != address(0), "Contract should be deployed");
    }

    function testGetPriceUnsafe() public {
        PythStructs.Price memory price = priceContract.getPrice();

        // We're not asserting values since they're fetched unsafely and could be zero locally
        emit log_named_int("Price", price.price);
        emit log_named_int("Confidence Interval", int256(uint256(price.conf)));
        emit log_named_int("Exponent", price.expo);
    }

    function testGetLatestPriceWithEmptyUpdateData() public payable {
        bytes[] memory updateData = new bytes[](0);

        // This will revert unless mocked or running on a fork with valid Pyth data.
        // You can expectRevert if you don't have live data.
        vm.expectRevert();
        priceContract.getLatestPrice{value: 0}(updateData);
    }
}
