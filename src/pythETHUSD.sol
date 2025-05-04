// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract PythETHUSD {
    IPyth public pyth;

    constructor() {
        pyth = IPyth(0xA2aa501b19aff244D90cc15a4Cf739D2725B5729);
    }

    function updatePriceFeed(bytes[] calldata priceUpdateData) public payable {
        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);
    }

    function getPrice() public view returns (PythStructs.Price memory) {
        bytes32 priceId = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
        return pyth.getPriceUnsafe(priceId);
    }

    function getLatestPrice(bytes[] calldata priceUpdateData) public payable returns (PythStructs.Price memory) {
        updatePriceFeed(priceUpdateData);
        return getPrice();
    } 
}