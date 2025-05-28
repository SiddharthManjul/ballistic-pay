// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import {Common} from "@chainlink/contracts/v0.8/libraries/Common.sol";
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/v0.8/automation/interfaces/ILogAutomation.sol";
import {IRewardManager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/IRewardManager.sol";
import {IVerifierFeeManager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/IVerifierFeeManager.sol";
import {IERC20} from "@chainlink/contracts/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/interfaces/IERC20.sol";

interface IVerifierProxy {

    function verify (
        bytes calldata payload,
        bytes calldata parameterPayload
    ) external payable returns (bytes memory verfierResponse);

    function s_feedManager() external view returns (IVerifierFeeManager);
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

contract StreamsUpkeep is ILogAutomation, StreamsLookupCompatibleInterface {
    error InvalidReportVersion(uint16 version);

    struct ReportV3 {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationsTimestamp;
        uint192 nativeTime;
        uint192 linkFee;
        uint32 expiresAt;
        int192 price;
        int192 bid;
        int192 ask;
    }

    struct ReportV4 {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationsTimestamp;
        uint192 nativeTime;
        uint192 linkFee;
        uint32 expiresAt;
        int192 price;
        uint32 marketStatus;
    }

    struct Quote {
        address quoteAddress;
    }

    IVerifierProxy public verifier;

    address public FEE_ADDRESS;
    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";
    int192 public lastDecodedPrice;

    string[] public feedIds = [
       "0x000359843a543ee2fe414dc14c7e7920ef10f4372990b79d6361cdc0dd1ba782" 
    ];

    constructor(address _verifier) {
        verifier = IVerifierProxy(_verifier);
    }

    function checkLog(
        Log calldata log,
        bytes memory
    ) external returns (bool upkeepNeeded, bytes memory performData) {
        revert StreamsLookup(
            DATASTREAMS_FEEDLABEL,
            feedIds,
            DATASTREAMS_QUERYLABEL,
            log.timestamp,
            ""
        );
    }

    function checkErrorHandler(
        uint256,
        bytes memory
    ) external pure returns (bool upkeepNeeded, bytes memory performData) {
        return (true, "0");
    }

    function checkCallback(
        bytes[] calldata values,
        bytes calldata extraData
    ) external pure returns (bool, bytes memory) {
        return (true, abi.encode(values, extraData));
    }

    function performUpkeep(bytes calldata performData) external {
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(
            performData,
            (bytes[], bytes)
        );

        bytes memory unverifiedReport = signedReports[0];

        (, bytes memory reportData) = abi.decode(unverifiedReport, (bytes32[3], bytes));

        uint16 reportVersion = (uint16(uint8(reportData[0])) << 8) |
            uint16(uint8(reportData[1]));

        if (reportVersion != 3 && reportVersion != 4) {
            revert InvalidReportVersion(uint8(reportVersion));
        }

        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));
        IRewardManager rewardManager = IRewardManager(
            address(feedManager.i_rewardManager())
        );

        address feeTokenAddress = feeManager.i_linkAddress();
        (Common.Asset memory fee, , ) = feeManager.getFeeAndReward(
            address(this),
            reportData,
            feeTokenAddress
        );

        IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);

        bytes memory verifiedReportData = verifier.verify(
            unverifiedReport,
            abi.encode(feeTokenAddress)
        );

        if (reportVersion == 3) {
            ReportV3 memory verifiedReport = abi.decode(
                verifiedReportData,
                (ReportV3)
            );
        }
    }
}