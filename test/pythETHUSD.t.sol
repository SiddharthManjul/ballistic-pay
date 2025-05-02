// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/Test.sol";
import { PythETHUSD } from "../src/PythETHUSD.sol";
import { MockPyth } from "@pythnetwork/pyth-sdk-solidity/MockPyth.sol";

contract PythETHUSDTest is Test {
    MockPyth public pyth;
    bytes32 ETH_PRICE_FEED_ID = bytes32(uint256(0x1));
    PythETHUSD public pythETHUSD;

    uint256 ETH_TO_WEI = 10 ** 18;

    function setUp() public {
        pyth = new MockPyth(60, 1);
        pythETHUSD = new PythETHUSD(address(pyth), ETH_PRICE_FEED_ID);
    }

    function createEthUpdate(int64 ethPrice) private view returns (bytes[] memory) {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = pyth.createPriceFeedUpdateData(
            ETH_PRICE_FEED_ID,
            ethPrice * 100000,
            10 * 100000,
            -5,
            ethPrice * 100000,
            10 * 100000,
            uint64(block.timestamp),
            uint64(block.timestamp)
        );
        return updateData;
    }

    function setEthPrice(int64 ethPrice) private {
        bytes[] memory updateData = createEthUpdate(ethPrice);
        uint value = pyth.getUpdateFee(updateData);
        vm.deal(address(this), value);
        pyth.updatePriceFeeds{ value: value }(updateData);
    }

    function testMint() public {
        setEthPrice(100);

        vm.deal(address(this), ETH_TO_WEI);
        pythETHUSD.mint{ value: ETH_TO_WEI/100 }();
    }

    function testMintRevert() public {
        setEthPrice(99);

        vm.deal(address(this), ETH_TO_WEI);
        vm.expectRevert();
        pythETHUSD.mint{ value: ETH_TO_WEI/100 }();
    }

    function testMintStalePrice() public {
        setEthPrice(100);
        skip(120);
        vm.deal(address(this), ETH_TO_WEI);
        vm.expectRevert();
        pythETHUSD.mint{value: ETH_TO_WEI/100}();
    }

    function testUpdateAndMint() public {
        bytes[] memory updateData = createEthUpdate(100);

        vm.deal(address(this), ETH_TO_WEI);
        pythETHUSD.updateAndMint{value: ETH_TO_WEI/100}(updateData);
    }
}