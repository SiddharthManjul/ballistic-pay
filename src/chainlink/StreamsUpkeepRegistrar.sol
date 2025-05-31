// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import {Common} from "@chainlink/contracts/v0.8/libraries/Common.sol";
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/v0.8/automation/interfaces/ILogAutomation.sol";
import {IRewardManager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/IRewardManager.sol";
import {IVerifierFeeManager} from "@chainlink/contracts/v0.8/llo-feeds/interfaces/IVerifierFeeManager.sol";
import {IERC20} from "@chainlink/contracts/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/interfaces/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/v0.8/shared/interfaces/LinkTokenInterface.sol";

struct RegistrationParams {
    string name;
    bytes encryptedEmail;
    address upkeepContract;
    uint32 gasLimit;
    address adminAddress;
    uint8 triggerType;
    bytes checkData;
    bytes triggerConfig;
    bytes offchainConfig;
    uint96 amount;
}

interface AutomationRegistrarInterface {
    function registerUpkeep(RegistrationParams calldata requestParams) external returns (uint256); 
}

interface IVerfierProxy {
    function verify(
        bytes calldata payload,
        bytes calldata parameterPayload
    ) external payable returns (bytes memory verifierResponse);

    function s_feeManager() external view returns (IVerifierFeeManager);
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

contract StreamsUpkeepRegistrar is ILogAutomation, StreamsLookupCompatibleInterface {
    error InvalidReportVersion(uint16 version);

    struct ReportV3 {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationTimestamp;
        uint192 nativeFee;
        uint192 linkFee;
        uint32 expiresAt;
        int192 price;
        int192 bid;
        int192 ask;
    }

    struct ReportV4 {
        bytes32 feedId;
        uint32 validFromTimestamp;
        uint32 observationTimestamp;
        uint192 nativeFee;
        uint192 linkFee;
        uint32 expiresAt;
        uint192 price;
        uint32 marketStatus;
    }

    struct Quote {
        address quoteAddress;
    }

    event PriceUpdate(int192 indexed price);

    IVeriferProxy public verifier;

    address public FEE_ADDRESS;
    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";
    int192 public lastDecodedPrice;
    uint256 s_upkeepID;
    bytes public s_LogTriggerConfig;

    string[] public feedIds;

    constructor(
        address _verifier,
        LinkTokenInterface link,
        AutomationRegistrarInterface registrar,
        string[] memory _feedIds
    ) {
        verifier = IVerifierProxy(_verifier);
        i_link = link;
        i_registrar = registrar;
        feedIds = _feedIds;
    }

    function registerAndPredictID(RegistrationParams memory params) public {
        i_link.approve(address(i_registrar), params.amount);
        uint256 upkeepID = i_registrar.registerUpkeep(params);
        if (upkeepID != 0) {
            s_upkeepID = upkeepID; // DEV - Use the upkeepID however you see fit
        } else {
            revert("auto-approve disabled");
        }
    }

    function checkErrorHandler(uint256, /*errCode*/ bytes memory /*extraData*/ )
        external
        pure
        returns (bool upkeepNeeded, bytes memory performData)
    {
        return (true, "0");
    }

    function checkLog(Log calldata log, bytes memory) external returns (bool upkeepNeeded, bytes memory performData) {
        revert StreamsLookup(DATASTREAMS_FEEDLABEL, feedIds, DATASTREAMS_QUERYLABEL, log.timestamp, "");
    }

    function checkCallback(bytes[] calldata values, bytes calldata extraData)
        external
        pure
        returns (bool, bytes memory)
    {
        return (true, abi.encode(values, extraData));
    }

    function performUpkeep(bytes calldata performData) external {
        // Decode the performData bytes passed in by CL Automation.
        // This contains the data returned by your implementation in checkCallback().
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(performData, (bytes[], bytes));

        bytes memory unverifiedReport = signedReports[0];

        (, /* bytes32[3] reportContextData */ bytes memory reportData) =
            abi.decode(unverifiedReport, (bytes32[3], bytes));

        // Extract report version from reportData
        uint16 reportVersion = (uint16(uint8(reportData[0])) << 8) | uint16(uint8(reportData[1]));

        // Validate report version
        if (reportVersion != 3 && reportVersion != 4) {
            revert InvalidReportVersion(uint8(reportVersion));
        }

        // Report verification fees
        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));
        IRewardManager rewardManager = IRewardManager(address(feeManager.i_rewardManager()));

        address feeTokenAddress = feeManager.i_linkAddress();
        (Common.Asset memory fee,,) = feeManager.getFeeAndReward(address(this), reportData, feeTokenAddress);

        // Approve rewardManager to spend this contract's balance in fees
        IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);

        // Verify the report
        bytes memory verifiedReportData = verifier.verify(unverifiedReport, abi.encode(feeTokenAddress));

        // Decode verified report data into the appropriate Report struct based on reportVersion
        if (reportVersion == 3) {
            // v3 report schema
            ReportV3 memory verifiedReport = abi.decode(verifiedReportData, (ReportV3));

            // Store the price from the report
            lastDecodedPrice = verifiedReport.price;
        } else if (reportVersion == 4) {
            // v4 report schema
            ReportV4 memory verifiedReport = abi.decode(verifiedReportData, (ReportV4));

            // Store the price from the report
            lastDecodedPrice = verifiedReport.price;
        }
    }
}