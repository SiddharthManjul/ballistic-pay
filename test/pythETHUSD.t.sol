// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PythETHUSD.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

// Mock implementation of IPyth for testing
contract MockPyth is IPyth {
    uint256 public mockUpdateFee = 0.01 ether;
    mapping(bytes32 => PythStructs.Price) public mockPrices;
    
    // ETH/USD price ID from the contract
    bytes32 public constant ETHUSD_PRICE_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;

    constructor() {
        // Initialize with a default mock price
        mockPrices[ETHUSD_PRICE_ID] = PythStructs.Price({
            price: 2000 * 10**8, // $2000.00
            conf: (10 * 10**8) / 100, // $10.00 as confidence interval
            expo: -8,
            publishTime: uint64(block.timestamp)
        });
    }

    function getUpdateFee(bytes[] calldata updateData) external view override returns (uint256) {
        return mockUpdateFee;
    }

    function getValidTimePeriod() external view returns (uint256) {
        return 60; // 60 seconds validity period
    }

    function getPriceUnsafe(bytes32 priceId) external view override returns (PythStructs.Price memory) {
        require(mockPrices[priceId].publishTime > 0, "Price not found");
        return mockPrices[priceId];
    }

    function getPrice(bytes32 priceId) external view returns (PythStructs.Price memory) {
        require(mockPrices[priceId].publishTime > 0, "Price not found");
        return mockPrices[priceId];
    }

    function getPriceNoOlderThan(bytes32 priceId, uint64 age) external view returns (PythStructs.Price memory) {
        require(mockPrices[priceId].publishTime > 0, "Price not found");
        require(block.timestamp - mockPrices[priceId].publishTime <= age, "Price too old");
        return mockPrices[priceId];
    }

    function updatePriceFeeds(bytes[] calldata updateData) external payable override {
        require(msg.value >= mockUpdateFee, "Not enough fee");
        // This is a mock, so we don't actually need to use the updateData
        // In a real scenario, we would parse updateData and update prices accordingly
    }

    function updatePriceFeedsIfNecessary(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds,
        uint64[] calldata publishTimes
    ) external payable override {
        require(msg.value >= mockUpdateFee, "Not enough fee");
        // Mock implementation - just ensure arrays match in length
        require(priceIds.length == publishTimes.length, "Mismatched arrays");
    }

    function parsePriceFeedUpdates(
        bytes[] calldata updateData,
        bytes32[] calldata priceIds
    ) external payable returns (PythStructs.PriceFeed[] memory) {
        require(msg.value >= mockUpdateFee, "Not enough fee");
        
        PythStructs.PriceFeed[] memory feeds = new PythStructs.PriceFeed[](priceIds.length);
        for (uint i = 0; i < priceIds.length; i++) {
            bytes32 id = priceIds[i];
            PythStructs.Price memory currentPrice = mockPrices[id];
            
            feeds[i] = PythStructs.PriceFeed({
                id: id,
                price: currentPrice,
                emaPrice: currentPrice // Using same price for EMA in mock
            });
        }
        
        return feeds;
    }

    // Additional helper functions for testing
    function setMockPrice(bytes32 priceId, int64 price, uint64 conf, int32 expo, uint64 publishTime) external {
        mockPrices[priceId] = PythStructs.Price({
            price: price,
            conf: conf,
            expo: expo,
            publishTime: publishTime
        });
    }

    function setUpdateFee(uint256 newFee) external {
        mockUpdateFee = newFee;
    }
}

contract PythETHUSDTest is Test {
    PythETHUSD public pythEthUsd;
    MockPyth public mockPyth;
    
    bytes32 public constant ETHUSD_PRICE_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
    
    // Setup function that runs before each test
    function setUp() public {
        mockPyth = new MockPyth();
        pythEthUsd = new PythETHUSD(address(mockPyth));
        
        // Fund the test contract with ETH for paying update fees
        vm.deal(address(this), 10 ether);
    }
    
    // Test getting ETH/USD price
    function testGetEthUsdPrice() public {
        // Set a specific price in our mock
        mockPyth.setMockPrice(
            ETHUSD_PRICE_ID,
            2500 * 10**8, // $2500.00
            (15 * 10**8) / 100, // $15.00 confidence
            -8,
            uint64(block.timestamp)
        );
        
        // Create dummy update data (content doesn't matter for our mock)
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mock data");
        
        // Get the price
        PythStructs.Price memory price = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        
        // Verify the price matches what we set
        assertEq(price.price, 2500 * 10**8);
        assertEq(price.conf, (15 * 10**8) / 100);
        assertEq(price.expo, -8);
        assertEq(price.publishTime, uint64(block.timestamp));
    }
    
    // Test with insufficient fee
    function testInsufficientFee() public {
        // Set update fee to 0.02 ETH
        mockPyth.setUpdateFee(0.02 ether);
        
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mock data");
        
        // Should revert because we're not sending enough ETH
        vm.expectRevert("Not enough fee");
        pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
    }
    
    // Test price conversion helper (convert the price to a human-readable format)
    function testPriceConversion() public {
        // Set price to $3000
        mockPyth.setMockPrice(
            ETHUSD_PRICE_ID,
            3000 * 10**8,
            (20 * 10**8) / 100,
            -8,
            uint64(block.timestamp)
        );
        
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mock data");
        
        PythStructs.Price memory price = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        
        // Convert to human-readable price (assuming expo is -8)
        int256 humanReadablePrice = price.price / int256(10**uint256(uint32(-price.expo)));
        assertEq(humanReadablePrice, 3000);
    }
    
    // Test with price update
    function testPriceUpdate() public {
        // Set initial price
        mockPyth.setMockPrice(
            ETHUSD_PRICE_ID,
            3000 * 10**8,
            (20 * 10**8) / 100,
            -8,
            uint64(block.timestamp)
        );
        
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mock data");
        
        // Get initial price
        PythStructs.Price memory initialPrice = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        assertEq(initialPrice.price, 3000 * 10**8);
        
        // Update price in mock
        mockPyth.setMockPrice(
            ETHUSD_PRICE_ID,
            3200 * 10**8,
            (25 * 10**8) / 100,
            -8,
            uint64(block.timestamp + 60)
        );
        
        // Get updated price
        PythStructs.Price memory updatedPrice = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        assertEq(updatedPrice.price, 3200 * 10**8);
        assertEq(updatedPrice.publishTime, uint64(block.timestamp + 60));
    }
    
    // Additional test to verify the correct price ID is being used
    function testCorrectPriceId() public {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mock data");
        
        // Set the price for the correct ID
        mockPyth.setMockPrice(
            ETHUSD_PRICE_ID,
            3000 * 10**8,
            (20 * 10**8) / 100,
            -8,
            uint64(block.timestamp)
        );
        
        // Should succeed with the correct price ID
        PythStructs.Price memory price = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        assertEq(price.price, 3000 * 10**8);
        
        // Set a different price ID (just for testing)
        bytes32 wrongPriceId = keccak256("WRONG_PRICE_ID");
        mockPyth.setMockPrice(
            wrongPriceId, 
            9999 * 10**8, 
            (50 * 10**8) / 100, 
            -8, 
            uint64(block.timestamp)
        );
        
        // Should still return the ETH/USD price, not the wrong price
        price = pythEthUsd.getEthUsdPrice{value: 0.01 ether}(updateData);
        assertEq(price.price, 3000 * 10**8); // Should be original price, not 9999
    }
    
    // Receive function to allow contract to receive ETH refunds
    receive() external payable {}
}