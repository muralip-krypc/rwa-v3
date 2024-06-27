// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EntityRegistration.sol";

contract initiatingTokenization is EntityRegistration{

    struct assetDetail{
        address propertyOwner;
        string[] doc;
        uint propertyValue;
    }

    struct serviceProviderDetail{
        address financialAdvisorAddress;
        address legalCouncilAddress;
        address realEstateValuer;
        address taxAdvisor;
    }

    struct feedbackDetails{
        address feedbackBy;
        string feedback;
    }

    mapping(string => assetDetail) public assetRegistration;
    mapping(string => serviceProviderDetail) public addServiceProviderDetail;
    mapping(string => feedbackDetails[]) public feedbackByServiceProvider;
    mapping(string => mapping(address => string)) public productStructuringsByFinancialAdvisor;

    event assetRegistrationByPropertyOwner(address indexed propertyOwner, string propertyId);
    event financialServiceProviderRegister(address indexed propertyOwner, address indexed financialAdvisorAddress, string propertyId);
    event legalServiceProviderRegister(address indexed propertyOwner, address indexed _legalCouncilAddress, string propertyId);
    event realEstateValuerServiceProviderRegister(address indexed propertyOwner, address indexed realEstateValuer, string propertyId);
    event TaxAdvisorServiceProviderRegister(address indexed propertyOwner, address indexed taxAdvisor,string _propertyId);

    function addAsset(string memory _propertyId, string[] memory _doc) public {
        address propertyOwner = _msgSender();
        assetDetail memory _assetReg = assetRegistration[_propertyId];
        require(_assetReg.propertyOwner == address(0),"asset already registered");
        require(isValidPropertyOwner(propertyOwner),"not a valid land Owner");
        _assetReg.propertyOwner = propertyOwner;
        _assetReg.doc = _doc;
        assetRegistration[_propertyId] = _assetReg;
        emit assetRegistrationByPropertyOwner(propertyOwner, _propertyId);
    }   

    function addFinancialAdvisorToProperty(string memory _propertyId, address _financialAdvisorAddress) public {
        address propertyOwner = _msgSender();
        require(isValidFinancialAdvisor(_financialAdvisorAddress),"not a valid financial Advisor");
        require(assetRegistration[_propertyId].propertyOwner == propertyOwner,"asset not registered or caller is not the property Owner");    
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId];
        _service.financialAdvisorAddress = _financialAdvisorAddress;
        addServiceProviderDetail[_propertyId] = _service;
        emit financialServiceProviderRegister(propertyOwner,_financialAdvisorAddress, _propertyId);
    }

    function propertyDueDiligenceByFinancialAdvisor(string memory _propertyId, string memory _feedback) public{
        address _financialAdvisorAddress = _msgSender();
        require(assetRegistration[_propertyId].propertyOwner != address(0),"asset not registered");  
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId]; 
        require(_service.financialAdvisorAddress == _financialAdvisorAddress,"not a valid financial service Provider for the property id");
        feedbackDetails[] storage feedbackArray = feedbackByServiceProvider[_propertyId];
        feedbackDetails memory _feed;
        _feed.feedbackBy = _financialAdvisorAddress;
        _feed.feedback = _feedback;
        feedbackArray.push(_feed);
    }

    function productStructuringByFinancialAdvisor(string memory _propertyId, string memory _feedback) public{
        address _financialAdvisorAddress = _msgSender(); 
        require(assetRegistration[_propertyId].propertyOwner != address(0),"asset not registered");  
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId]; 
        require(_service.financialAdvisorAddress == _financialAdvisorAddress,"not a valid financial service Provider for the property id");
        productStructuringsByFinancialAdvisor[_propertyId][_financialAdvisorAddress] = _feedback;
    }

    function addLegalCouncilToProperty(string memory _propertyId, address _legalCouncilAddress) public {
        address propertyOwner = _msgSender();
        require(isValidLegalCounsel(_legalCouncilAddress),"not a valid legal Council member");
        require(assetRegistration[_propertyId].propertyOwner == propertyOwner,"asset not registered or caller is not the property Owner");    
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId];
        _service.legalCouncilAddress = _legalCouncilAddress;
        addServiceProviderDetail[_propertyId] = _service;
        emit legalServiceProviderRegister(propertyOwner,_legalCouncilAddress,_propertyId);
    }

    function feedbackByLegalCouncil(string memory _propertyId, string memory _feedback) public{
        address _legalCouncilAddress = _msgSender();
        require(assetRegistration[_propertyId].propertyOwner != address(0),"asset not registered");  
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId]; 
        require(_service.legalCouncilAddress == _legalCouncilAddress,"not a valid legal service Provider for the property id");
        feedbackDetails[] storage feedbackArray = feedbackByServiceProvider[_propertyId];
        feedbackDetails memory _feed;
        _feed.feedbackBy = _legalCouncilAddress;
        _feed.feedback = _feedback;
        feedbackArray.push(_feed);
    }

    function addTaxAdvisorToProperty(string memory _propertyId, address _taxAdvisor) public {
        address _propertyOwner = _msgSender();
        require(isValidTaxAdvisor(_taxAdvisor),"not a valid legal Council member");
        require(assetRegistration[_propertyId].propertyOwner == _propertyOwner,"asset not registered or caller is not the property Owner");    
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId];
        _service.taxAdvisor = _taxAdvisor;
        addServiceProviderDetail[_propertyId] = _service;
        emit TaxAdvisorServiceProviderRegister(_propertyOwner,_taxAdvisor,_propertyId);
    }

    function feedbackByTaxAdvisor(string memory _propertyId, string memory _feedback) public{
        address _taxAdvisor = _msgSender();
        require(assetRegistration[_propertyId].propertyOwner != address(0),"asset not registered");  
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId]; 
        require(_service.taxAdvisor == _taxAdvisor,"not a valid tax Advisor service Provider for the property id");
        feedbackDetails[] storage feedbackArray = feedbackByServiceProvider[_propertyId];
        feedbackDetails memory _feed;
        _feed.feedbackBy = _taxAdvisor;
        _feed.feedback = _feedback;
        feedbackArray.push(_feed);
    }

    function ModifyingAsset(string memory _propertyId, string[] memory _doc) public {
        address _propertyOwner = _msgSender();
        assetDetail memory _assetReg = assetRegistration[_propertyId];
        require(_assetReg.propertyOwner == _propertyOwner,"asset not registered or caller is not the property Owner");
        delete _assetReg.doc;
        _assetReg.doc = _doc;
        assetRegistration[_propertyId] = _assetReg;
    }

    function addRealEstateServiceProvider(string memory _propertyId, address _realEstateValuer) public{
        address _propertyOwner = _msgSender();
        require(assetRegistration[_propertyId].propertyOwner == _propertyOwner,"asset not registered or property Owner is not the caller");  
        require(isValidRealEstateValuer(_realEstateValuer),"not a valid real Estate Valuer");
        serviceProviderDetail memory _service = addServiceProviderDetail[_propertyId]; 
        _service.realEstateValuer = _realEstateValuer;   
        addServiceProviderDetail[_propertyId] = _service;
        emit legalServiceProviderRegister(_propertyOwner,_realEstateValuer,_propertyId);
    }

    function propertyValuation(string memory _propertyId, uint _propertyValue) public {
        assetDetail memory _assetReg = assetRegistration[_propertyId];
        require(_assetReg.propertyOwner != address(0),"asset not registered"); 
        require(isValidRealEstateValuer(_msgSender()),"caller is not a valid real Estate Valuer");
        _assetReg.propertyValue = _propertyValue;
        assetRegistration[_propertyId] = _assetReg;
    }

    function getAssetDoc(string memory _propertyId) public view returns (address _propertyOwner,string[] memory doc) {
        return (assetRegistration[_propertyId].propertyOwner,assetRegistration[_propertyId].doc);
    }

    function getFeedbackPerServiceProvider(string memory _propertyId, address _serviceProvider) public view returns (string[] memory) {
        feedbackDetails[] memory feedbackArray = feedbackByServiceProvider[_propertyId];
        uint count = 0; 
        for (uint i = 0; i < feedbackArray.length; i++) {
            if (feedbackArray[i].feedbackBy == _serviceProvider) {
                count++;
            }
        }
        string[] memory _feedback = new string[](count);
        uint index = 0;
        for (uint i = 0; i < feedbackArray.length; i++) {
            if (feedbackArray[i].feedbackBy == _serviceProvider) {
                _feedback[index] = feedbackArray[i].feedback;
                index++;
            }
        }
        return _feedback;
    }
}