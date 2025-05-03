// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

// Import your EthUsdReader contract here
import "../src/PythETHUSD.sol";

contract MockPyth is IPyth {
    function getPriceUnsafe(bytes32 id) external pure override returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    ) {
        // Return mock values for testing
        return (2000e8, 10e8, -8, 1700000000);
    }
}

contract PythETHUSDTest is Test {
    PythETHUSD public reader;
    MockPyth public mockPyth;

    function setUp() public {
        mockPyth = new MockPyth();
        reader = new PythETHUSD(address(mockPyth));
    }

    function testGetEthUsdPrice() public view {
        (int64 price, uint64 conf, int32 expo, uint256 publishTime) = reader.getEthUsdPrice();
        assertEq(price, 2000e8);
        assertEq(conf, 10e8);
        assertEq(expo, -8);
        assertEq(publishTime, 1700000000);
    }
}
