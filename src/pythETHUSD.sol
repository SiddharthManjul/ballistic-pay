// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

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

contract PythETHUSD {
    address public immutable pythContract;
    bytes32 public constant ETH_USD_FEED_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;

    constructor(address _pythContract) {
        pythContract = _pythContract;
    }

    /// @notice Updates the price feed and returns the latest ETH/USD price.
    /// @param updateData The latest price update data (from Pyth off-chain service).
    function updateAndGetEthUsdPrice(bytes[] calldata updateData)
        external
        payable
        returns (int64 price, uint64 conf, int32 expo, uint256 publishTime)
    {
        // Forward the required fee and update the price feeds
        IPyth(pythContract).updatePriceFeeds{value: msg.value}(updateData);

        // Now return the latest price
        return IPyth(pythContract).getPriceUnsafe(ETH_USD_FEED_ID);
    }

    /// @notice Helper to compute the required fee for a given updateData
    function getUpdateFee(bytes[] calldata updateData) external view returns (uint256) {
        return IPyth(pythContract).getUpdateFee(updateData);
    }
}
