// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AssetTokenization.sol";
import "./Ownable.sol";
import "./KycValidation.sol";
import "./CountryValidation.sol";
import "./InvestorTokenLimit.sol";
import "./Whitelist.sol";
import "./Blacklist.sol";
import "./TimeboundInvestment.sol";

interface IkycCon {
    function isValidPropertyOwner(address _propertyOwner) external view returns(bool);
    function isValidCustodian(address _custodian) external view returns(bool);
}

contract AssetTokenizationFactory is Ownable {

    struct assetTokenDeploymentDetails {
        address assetOwner;
        address custodian;
        uint256 tokenId;
        uint256 initialSupply;
        bytes32 salt;
        bytes data;
        string uri;
        string projectDetails;
    }

    struct assetRegisterByCustodian {
        uint256 totalAgreedMonthsTimeStamp;
        uint256 minDividendPay;
        uint256 maxDividendPay;
        uint256 commission;
        uint256 tokenPrice;
        bool isContractDeployed;
    }

    struct TokenizationConditions {
        bool kycValidationEnabled;
        bool countryValidationEnabled;
        bool investorTokenLimitEnabled;
        bool whitelistEnabled;
        bool blacklistEnabled;
        bool timeBoundInvestmentEnabled;
        string[] restrictedCountries;
        address[] whitelistedAddresses;
        address[] blacklistedAddresses;
        uint256 maxTokenLimit;
        uint256 saleStartTime;
        uint256 saleEndTime;
    }

    mapping(address => assetRegisterByCustodian) public assetOwnerAgreementDetails;
    mapping(address => mapping(address => bool)) public assetOwnerCustodianlinked;
    mapping(address => assetTokenDeploymentDetails) public assetDetails;
    address[] public deployedAssetContract;
    address public kycDetailsContract;
    address public countryValidationContract;
    address public tokenLimitContract;
    address public whitelistContract;
    address public blacklistContract;
    address public timeBoundContract;

    event AssetTokenized(address indexed _assetOwner, address indexed _assetContract);
    event assetOwnerCustodianConnected(address indexed _assetOwner, address indexed _custodian);
    event assetOwnerCustodianDisconnected(address indexed _assetOwner, address indexed _custodian);
    event AgreementActivated(address indexed _assetContractAddress, address indexed _assetOwner, address indexed _custodian);

    constructor(
        address _kycDetailsContract,
        address _countryValidationContract,
        address _tokenLimitContract,
        address _whitelistContract,
        address _blacklistContract,
        address _timeBoundContract
    ) {
        kycDetailsContract = _kycDetailsContract;
        countryValidationContract = _countryValidationContract;
        tokenLimitContract = _tokenLimitContract;
        whitelistContract = _whitelistContract;
        blacklistContract = _blacklistContract;
        timeBoundContract = _timeBoundContract;
    }

    function assetOwnerCustodianLinking(address _custodian) public {
        address _assetOwner = _msgSender();
        require(!assetOwnerCustodianlinked[_assetOwner][_custodian], "asset owner already linked with custodian");
        IkycCon kycInterface = IkycCon(kycDetailsContract);
        require(kycInterface.isValidPropertyOwner(_assetOwner) && kycInterface.isValidCustodian(_custodian), "either _assetOwner or custodian is not verified");
        assetOwnerCustodianlinked[_assetOwner][_custodian] = true;
        emit assetOwnerCustodianConnected(_assetOwner, _custodian);
    }

    function assetOwnerCustodianDelinking(address _custodian) public {
        address _assetOwner = _msgSender();
        require(assetOwnerCustodianlinked[_assetOwner][_custodian], "asset owner already delinked with custodian");
        delete assetOwnerCustodianlinked[_assetOwner][_custodian];
        emit assetOwnerCustodianDisconnected(_assetOwner, _custodian);
    }

    function predictAssetTokenAddress(bytes32 salt, string memory _uri, address _custodian, uint256 _tokenId, uint256 _initialSupply, bytes memory _data) public view returns(address predictedAddress) {
        return predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt,
        keccak256(abi.encodePacked(type(AssetTokenization).creationCode, abi.encode(_uri, _custodian, _tokenId, _initialSupply, _data, kycDetailsContract)))
        )))));
    }

    function setAssetDetails(
        string memory _projectDetails,
        bytes32 _salt,
        string memory _uri,
        address _assetOwner,
        uint256 _tokenId,
        uint256 _initialSupply,
        bytes memory _data,
        uint256 _totalAgreedMonthsTimeStamp,
        uint256 _minDividendPay,
        uint256 _maxDividendPay,
        uint256 _commission
    ) public returns(address) {
        address _custodian = _msgSender();
        address predictedAddress = predictAssetTokenAddress(_salt, _uri, _custodian, _tokenId, _initialSupply, _data);  
        require(!assetOwnerAgreementStatus(predictedAddress), "contract already deployed");
        require(assetOwnerCustodianlinked[_assetOwner][_custodian], "assetOwner and custodian are not linked");
        assetTokenDeploymentDetails memory asset = assetDetails[predictedAddress];
        asset.assetOwner = _assetOwner;
        asset.custodian = _custodian;
        asset.tokenId = _tokenId;
        asset.initialSupply = _initialSupply;
        asset.salt = _salt;
        asset.data = _data;
        asset.uri = _uri;
        asset.projectDetails = _projectDetails;
        assetDetails[predictedAddress] = asset;
        activateAssetOwnerAgreement(predictedAddress, _assetOwner, _custodian, _totalAgreedMonthsTimeStamp, _minDividendPay, _maxDividendPay, _commission);
        return predictedAddress;
    }

    function activateAssetOwnerAgreement(
        address _assetContractAddress,
        address _assetOwner,
        address _custodian,
        uint256 _totalAgreedMonthsTimeStamp,
        uint256 _minDividendPay,
        uint256 _maxDividendPay,
        uint256 _commission
    ) internal {
        assetRegisterByCustodian memory assetRegister = assetOwnerAgreementDetails[_assetContractAddress];
        require(_totalAgreedMonthsTimeStamp > block.timestamp, "Agreement has no remaining time");
        require(assetRegister.totalAgreedMonthsTimeStamp == 0, "asset already registered");
        assetRegister.totalAgreedMonthsTimeStamp = _totalAgreedMonthsTimeStamp;
        assetRegister.minDividendPay = _minDividendPay;
        assetRegister.maxDividendPay = _maxDividendPay;
        assetRegister.commission = _commission;
        assetOwnerAgreementDetails[_assetContractAddress] = assetRegister;
        emit AgreementActivated(_assetContractAddress, _assetOwner, _custodian);
    }

    function deActivateAssetOwnerAgreement(address _assetContractAddress) public {
        assetRegisterByCustodian memory assetRegister = assetOwnerAgreementDetails[_assetContractAddress];
        require(assetRegister.totalAgreedMonthsTimeStamp != 0, "asset not registered");
        assetTokenDeploymentDetails memory asset = assetDetails[_assetContractAddress];
        require(asset.custodian == _msgSender(), "only registered custodian can deactivate the agreement");
        delete assetOwnerAgreementDetails[_assetContractAddress];
    }

    function deployAssetContract(
        address _assetContractAddress,
        uint _tokenPrice,
        TokenizationConditions memory conditions,
        string memory investorCountry
    ) public {
        address _assetOwner = _msgSender();
        assetTokenDeploymentDetails memory asset = assetDetails[_assetContractAddress];
        assetRegisterByCustodian memory _assetOwnerAgreementDetails = assetOwnerAgreementDetails[_assetContractAddress];
        require(!assetOwnerAgreementStatus(_assetContractAddress), "contract already deployed");
        require(asset.assetOwner == _assetOwner, "only assetOwner can deploy the asset contract");

        // KYC Validation
        if (conditions.kycValidationEnabled) {
            KycValidation kycValidation = KycValidation(kycDetailsContract);
            require(kycValidation.isValidInvestor(_assetOwner), "KYC validation failed");
        }

        // Country Validation
        if (conditions.countryValidationEnabled) {
            CountryValidation countryValidation = new CountryValidation(conditions.restrictedCountries);
            require(!countryValidation.isCountryRestricted(investorCountry), "Country validation failed");
        }

        // Investor Token Limit
        if (conditions.investorTokenLimitEnabled) {
            InvestorTokenLimit tokenLimit = new InvestorTokenLimit(conditions.maxTokenLimit);
            require(tokenLimit.validateTokenLimit(asset.initialSupply), "Investor token limit exceeded");
        }

        // Whitelist
        if (conditions.whitelistEnabled) {
            Whitelist whitelist = Whitelist(whitelistContract);
            for (uint i = 0; i < conditions.whitelistedAddresses.length; i++) {
                whitelist.addToWhitelist(conditions.whitelistedAddresses[i]);
            }
            require(whitelist.isWhitelisted(_assetOwner), "Whitelist validation failed");
        }

        // Blacklist
        if (conditions.blacklistEnabled) {
            Blacklist blacklist = Blacklist(blacklistContract);
            for (uint i = 0; i < conditions.blacklistedAddresses.length; i++) {
                blacklist.addToBlacklist(conditions.blacklistedAddresses[i]);
            }
            require(!blacklist.isBlacklisted(_assetOwner), "Blacklist validation failed");
        }

        // Time-bound Investment
        if (conditions.timeBoundInvestmentEnabled) {
            TimeBoundInvestment timeBound = TimeBoundInvestment(timeBoundContract);
            timeBound.setSalePeriod(conditions.saleStartTime, conditions.saleEndTime);
            require(timeBound.isSalePeriodActive(), "Time-bound investment period inactive");
        }

        AssetTokenization assetTokenContract = new AssetTokenization{salt: asset.salt}(asset.uri, asset.custodian, asset.tokenId, asset.initialSupply, asset.data, kycDetailsContract);
        require(address(assetTokenContract) == _assetContractAddress, "function parameter address is not same as the deployed contract address");
        deployedAssetContract.push(address(assetTokenContract));
        _assetOwnerAgreementDetails.isContractDeployed = true;
        _assetOwnerAgreementDetails.tokenPrice = _tokenPrice;
        assetOwnerAgreementDetails[_assetContractAddress] = _assetOwnerAgreementDetails;
        emit AssetTokenized(_assetOwner, _assetContractAddress);
    }

    function assetOwnerAgreementStatus(address _assetContractAddress) public view returns(bool) {
        assetRegisterByCustodian memory assetRegister = assetOwnerAgreementDetails[_assetContractAddress];
        return assetRegister.isContractDeployed;
    }

    function viewAssetDetailsByContractAddress(address _assetContract) public view returns(address _custodian, address _assetOwner, uint256 _commission, uint256 _tokenPrice, bool _isContractDeployed) {
        assetRegisterByCustodian memory assetOwnerAgreement = assetOwnerAgreementDetails[_assetContract];
        assetTokenDeploymentDetails memory asset = assetDetails[_assetContract];
        _custodian = asset.custodian;
        _assetOwner = asset.assetOwner;
        _commission = assetOwnerAgreement.commission;
        _tokenPrice = assetOwnerAgreement.tokenPrice;
        _isContractDeployed = assetOwnerAgreement.isContractDeployed;
    }
}
