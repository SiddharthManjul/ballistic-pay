// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Common} from "@chainlink/contracts/v0.8/libraries/Common.sol";
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/v0.8/automation/interfaces/ILogAutomation.sol";
import {IRewardanager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/IRewardManager.sol";
import {IVerfierFeeManager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/";
import {IERC20} from "@chainlink/contracts/v0.8/vendor/openzepplin-solidity/v4.8.0/contracts/interfaces/IERC20.sol";

interface IVerifierProxy {

    function verify (
        bytes calldata payload,
        bytes calldata parameterPayload
    ) external payable returns (bytes memory verfierResponse);

    function s_feedManager() external view returns (IVerfierFeeManager);
}

interface IFeeManager {
    function getFeeAndReward(
        address subscriber,
        bytes memory unverifiedReport,
        address quoteAddress
    ) external returns (Common.Asset memory, Common.Asset memory, uint256);

    function i_linkAddress() external view returns (address);
    function i_nativeAddress() external view returns (address);
    function i_rewardManager() external view returns (address);
}