// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IPyth {
    function getPriceUnsafe(bytes32 id) external view returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    );
}

contract PythETHUSD {
    // Replace with actual Pyth contract address on Base Sepolia
    address public immutable pythContract;

    // ETH/USD price feed ID (same on all chains)
    bytes32 public constant ETH_USD_FEED_ID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;

    constructor(address _pythContract) {
        pythContract = _pythContract;
    }

    function getEthUsdPrice() external view returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    ) {
        return IPyth(pythContract).getPriceUnsafe(ETH_USD_FEED_ID);
    }
}
