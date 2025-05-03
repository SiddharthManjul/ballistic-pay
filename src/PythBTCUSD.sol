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

contract PythBTCUSD {
    // Replace with actual Pyth contract address on Base Sepolia
    address public immutable pythContract;

    // ETH/USD price feed ID (same on all chains)
    bytes32 public constant BTC_USD_FEED_ID = 0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43;

    constructor(address _pythContract) {
        pythContract = _pythContract;
    }

    function getBtcUsdPrice() external view returns (
        int64 price,
        uint64 conf,
        int32 expo,
        uint256 publishTime
    ) {
        return IPyth(pythContract).getPriceUnsafe(BTC_USD_FEED_ID);
    }
}
