// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract BallisticPayStream {
    IPyth public pyth;

    constructor(address pythAddress) {
        pyth = IPyth(pythAddress);
    }

    function getBtcUsdPrice(bytes [] calldata priceUpdateData) public payable returns (PythStructs.Price memory) {
        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);
        bytes32 priceID = 0xf9c0172ba10dfa4d19088d94f5bf61d3b54d5bd7483a322a982e1373ee8ea31b;
        return pyth.getPriceNoOlderThan(priceID, 10);
    } 
}

