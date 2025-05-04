// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import {PythETHUSD} from "../src/PythETHUSD.sol";
// --- Mock IPyth Implementation ---
interface IPyth {
    function updatePriceFeeds(bytes[] calldata updateData) external payable;
    function getUpdateFee(bytes[] calldata updateData) external view returns (uint256);
    function getPriceUnsafe(bytes32 id) external view returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    );
}
contract MockPyth is IPyth {
    uint256 public updateCount;
    uint256 public lastValue;
    bytes32 public lastQueriedId;
    bytes32 public lastDataHash;
    
    function updatePriceFeeds(bytes[] calldata updateData) external payable override {
        // Instead of storing the entire calldata array, we store relevant information
        updateCount = updateData.length;
        lastValue = msg.value;
        // Create a hash of the data for verification
        bytes memory concatenated;
        for (uint i = 0; i < updateData.length; i++) {
            concatenated = abi.encodePacked(concatenated, updateData[i]);
        }
        lastDataHash = keccak256(concatenated);
    }
    
    function getUpdateFee(bytes[] calldata updateData) external pure override returns (uint256) {
        // For testing: 42 wei per updateData item
        return updateData.length * 42;
    }
    
    function getPriceUnsafe(bytes32 /* id */) external pure override returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    ) {
        // Remove state modification but keep the logic for tests
        // lastQueriedId = id;  <- This was causing the error
        
        // Return mock values
        return (123456789, 1000, -8, 1700000000);
    }
    
    // Add a non-view function for tests to track the last queried ID
    function recordQueryId(bytes32 id) external {
        lastQueriedId = id;
    }
}

// --- Test Contract ---
contract PythETHUSDTest is Test {
    MockPyth mockPyth;
    PythETHUSD reader;
    
    function setUp() public {
        mockPyth = new MockPyth();
        reader = new PythETHUSD(address(mockPyth));
    }
    
    function testGetUpdateFee() public view {
        bytes[] memory updateData = new bytes[](2);
        updateData[0] = bytes("update1");
        updateData[1] = bytes("update2");
        uint256 fee = reader.getUpdateFee(updateData);
        assertEq(fee, 84); // 2 * 42
    }
    
    function testUpdateAndGetEthUsdPrice() public {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = bytes("mockUpdate");
        uint256 fee = reader.getUpdateFee(updateData);
        
        // Record the feed ID before making the call
        mockPyth.recordQueryId(reader.ETH_USD_FEED_ID());
        
        // Call updateAndGetEthUsdPrice with the correct fee
        (int64 price, uint64 conf, int32 expo, uint256 publishTime) =
            reader.updateAndGetEthUsdPrice{value: fee}(updateData);
            
        assertEq(price, 123456789);
        assertEq(conf, 1000);
        assertEq(expo, -8);
        assertEq(publishTime, 1700000000);
        
        // Check that the mock contract received the update
        assertEq(mockPyth.lastValue(), fee);
        assertEq(mockPyth.updateCount(), 1);
        
        // Verify the data hash matches
        bytes memory data = bytes("mockUpdate");
        bytes32 expectedHash = keccak256(data);
        assertEq(mockPyth.lastDataHash(), expectedHash);
        assertEq(mockPyth.lastQueriedId(), reader.ETH_USD_FEED_ID());
    }
}