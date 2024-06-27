
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./SPVFormation.sol";
import "./IERC1155.sol";

interface Ikyc{
    function isValidPropertyOwner(address _propertyOwner) external view returns(bool);
    function isValidCustodian(address _custodian) external view returns(bool);
    function isValidMarketMaker(address _marketMaker) external view returns(bool);
    function isValidInvestor(address _investor) external view returns(bool);
    function isValidTaxAdvisor(address _taxAdvisor) external view returns(bool);
    function isValidFundAdministrator(address _fundAdministrator) external view returns(bool);
}

interface Iasset{
    function viewAssetDetailsByContractAddress(address _assetContract) external view returns(address custodian,address assetOwner,uint256 commission,uint256 tokenPrice, bool isContractDeployed);
}



contract MarketPlace is Ownable{

    struct assetDetail{
        uint tokenId;
        uint totalNoOfTokens;
        uint noOfTokensSold;
        uint lastOfferingTime;
    }

    struct investorDetail{
        address investor;
        uint tokenId;
        uint noOfTokens;
        uint investedAmount;
    }
 
    address public assetManagementContract;
    address public kycContract;

    mapping(address => assetDetail) public listedAsset;
    mapping(address => investorDetail[]) public listOfInvestorsInAsset;
    mapping(bytes => bool) signatureUsed;
    address[] public spvContracts;

    event assetListed(address indexed assetContract, address indexed custodian);
    event TokenPurchased(address indexed assetContract, address indexed investor, uint indexed noOfTokensPurchased);
    event spvFormed(address indexed assetContract, address indexed spvContract, address indexed custodian);
    event secondaryAssetSale(address indexed assetContract, address indexed oldInvestor, address indexed newInvestor);

    constructor(address _kycContract,address _assetManagementContract){
        assetManagementContract = _assetManagementContract;
        setKYCcontract(_kycContract);
    }

    function setAssetManagementContract(address _assetManagementContract) public onlyOwner{
        assetManagementContract = _assetManagementContract;        
    }

    function setKYCcontract(address _kycContract) public onlyOwner{
        kycContract =_kycContract;
    }

    function listingAssetContract(address _assetContract,uint256 _tokenId, uint256 _noOfTokens, uint _lastOfferingTime) public{
        assetDetail memory asset = listedAsset[_assetContract];
        Iasset assetInterface = Iasset(assetManagementContract);
        (address _custodian,,,, bool isContractDeployed)=assetInterface.viewAssetDetailsByContractAddress(_assetContract);
        require(asset.lastOfferingTime == 0,"already listed");
        require(isContractDeployed,"asset is not deployed");
        require(_custodian == _msgSender(),"caller is not custodian");
        require(block.timestamp <= _lastOfferingTime,"last offering time passed");
        asset.tokenId = _tokenId;
        asset.totalNoOfTokens = _noOfTokens;
        asset.lastOfferingTime =_lastOfferingTime;
        listedAsset[_assetContract] = asset;
        emit assetListed(_assetContract, _custodian);
    }

    function editListingAssetContractTime(address _assetContract, uint _lastOfferingTime) public{
        assetDetail memory asset = listedAsset[_assetContract];
        Iasset assetInterface = Iasset(assetManagementContract);
        (address _custodian,,,,)=assetInterface.viewAssetDetailsByContractAddress(_assetContract);
        require(asset.lastOfferingTime != 0,"asset not listed"); 
        require(_custodian == _msgSender(),"caller is not custodian"); 
        asset.lastOfferingTime =_lastOfferingTime;
        listedAsset[_assetContract] = asset;  
    }

    function calculatePriceOfTokenByAssetAddress(address _assetContract, uint _noOfTokens) public view returns(address _custodian,address _assetOwner,uint _totalPriceForOwner,uint _commissionAmount, uint _totalPrice){
        uint256 _commission;
        uint256 _tokenPrice;
        Iasset assetInterface = Iasset(assetManagementContract);
        (_custodian, _assetOwner,_commission,_tokenPrice,)=assetInterface.viewAssetDetailsByContractAddress(_assetContract);
        (_totalPriceForOwner,_commissionAmount,_totalPrice) = priceOfToken(_tokenPrice, _commission,_noOfTokens); 
        
    }
 
    function priceOfToken(uint _price, uint _commission, uint _noOfTokens) public pure returns(uint _totalPriceForOwner,uint _commissionAmount, uint _totalPrice){
        _totalPriceForOwner = _price * _noOfTokens; 
        _commissionAmount = (_totalPriceForOwner * _commission)/10000;
        _totalPrice += _totalPriceForOwner + _commissionAmount;    
    }

    function purchaseToken(address _assetContract, uint _noOfToken, uint _tokenId) public isAssetListed(_assetContract) payable {
        address currentInvestor = _msgSender();
        uint256 _totalPriceForOwner;
        assetDetail memory asset = listedAsset[_assetContract];
        investorDetail[] memory investors = listOfInvestorsInAsset[_assetContract];
        (address _custodian,address _assetOwner,uint256 _commission,uint256 _tokenPrice)=getAssetDetails(_assetContract);
        require(isInvestorVerified(currentInvestor),"user is not verified");
        require(asset.totalNoOfTokens >= asset.noOfTokensSold + _noOfToken,"all tokens are sold");
        (_totalPriceForOwner, _commission, _tokenPrice) = priceOfToken(_tokenPrice,_commission,_noOfToken);
        require(msg.value == _tokenPrice,"send amount is not same as required");
        payable(_assetOwner).transfer(_totalPriceForOwner);
        payable(_custodian).transfer(_commission);
        IERC1155(_assetContract).safeTransferFrom(_custodian, currentInvestor, _tokenId, _noOfToken, "");
        _totalPriceForOwner = 0;
        for (uint i; i < investors.length; i++) {
            if (investors[i].investor == currentInvestor && investors[i].tokenId == _tokenId) {
                _totalPriceForOwner = 1;
                _commission = i;
                break;
            }
        }    
        if (_totalPriceForOwner == 1) {
            listOfInvestorsInAsset[_assetContract][_commission].noOfTokens += _noOfToken;
        } else {
            investorDetail memory newInvestor = investorDetail(currentInvestor, _tokenId,_noOfToken, _tokenPrice);
            listOfInvestorsInAsset[_assetContract].push(newInvestor);
        }        
        asset.noOfTokensSold += _noOfToken;
        listedAsset[_assetContract] = asset;
        emit TokenPurchased(_assetContract, currentInvestor, _noOfToken);
    }

    function setUpSPV(address _assetContract, address _fundAdministrator, string memory _doc1, string memory _doc2) public returns(address) {
        assetDetail memory asset = listedAsset[_assetContract];
        Iasset assetInterface = Iasset(assetManagementContract);
        (address _custodian,,,,)=assetInterface.viewAssetDetailsByContractAddress(_assetContract);
        Ikyc kycInterface = Ikyc(kycContract);
        bool status = kycInterface.isValidFundAdministrator(_fundAdministrator);
        require(status, "_fundAdministrator is not the registered fund administrator");
        require(asset.lastOfferingTime != 0,"asset not listed");
        require(_custodian == _msgSender(),"caller is not custodian");
        require(block.timestamp >= asset.lastOfferingTime,"last offering time not passed");  
        SPVFormation spvFormation = new SPVFormation(assetManagementContract, _assetContract, asset.tokenId, _fundAdministrator, _doc1, _doc2); 
        spvContracts.push(address(spvFormation));  
        emit spvFormed(_assetContract,address(spvFormation),_custodian); 
        return address(spvFormation);
    }

    modifier isAssetListed(address _assetContract) {
        require(block.timestamp <= listedAsset[_assetContract].lastOfferingTime," asset is not listed or last offering time ended");
        _;
    }
 
    function isInvestorVerified(address _investor) public view returns(bool status){
        Ikyc kycInterface = Ikyc(kycContract);
        status = kycInterface.isValidInvestor(_investor);    
    }

    function getAssetDetails(address _assetContract)public view returns(address _custodian,address _assetOwner,uint256 _commission,uint256 _tokenPrice){
        Iasset assetInterface = Iasset(assetManagementContract);
        (_custodian, _assetOwner, _commission, _tokenPrice, )=assetInterface.viewAssetDetailsByContractAddress(_assetContract);
    }

    function getInvestorInvestmentDetails(address _assetContract, uint256 _tokenId) public view returns(uint256 _noOfToken, uint256 _investedAmount){
        investorDetail[] memory investors = listOfInvestorsInAsset[_assetContract];
        address currentInvestor = _msgSender();
        bool investmentExist;
        uint index;
        for (uint i; i < investors.length; i++) {
            if (investors[i].investor == currentInvestor && investors[i].tokenId == _tokenId) {
                investmentExist = true;
                index = i;
                break;
            }
        }    
        if (investmentExist) {
            _noOfToken = investors[index].noOfTokens;
            _investedAmount = investors[index].investedAmount;
            return (_noOfToken,_investedAmount);
        } else {
            return (0,0);
        }        
    }
}

