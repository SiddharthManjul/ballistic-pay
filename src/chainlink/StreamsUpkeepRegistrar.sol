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
        string[] memory _feedIds,
    ) {
        verifier = IVerifierProxy(_verifier);
        i_link = link;
        i_registrar = registrar;
        feedIds = _feedIds;
    }
}