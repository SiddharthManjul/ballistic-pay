// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

contract PythETHUSD {
    IPyth pyth;

    constructor(address pythContract) {
        pyth = IPyth(pythContract);
    }

    function getEthUsdPrice(bytes[] calldata priceUpdateData) public payable returns (PythStructs.Price memory) {
        uint fee = pyth.getUpdateFee(priceUpdateData);
        pyth.updatePriceFeeds{value: fee}(priceUpdateData);

        bytes32 priceID = 0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace;
        return pyth.getPriceUnsafe(priceID);
    }
}