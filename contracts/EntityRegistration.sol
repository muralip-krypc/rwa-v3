// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PlatformGovernance.sol";

contract EntityRegistration is PlatformGovernance {

    mapping(address => string) public propertyOwners;
    mapping(address => string) public custodians;
    mapping(address => string) public marketMakers;
    mapping(address => string) public investors;
    mapping(address => string) public taxAdvisors;
    mapping(address => string) public fundAdministrators;
    mapping(address => string) public realEstateValuers;
    mapping(address => string) public legalCouncils;
    mapping(address => string) public financialAdvisors;
    mapping(address => string) public techAdvisor;
    mapping(address => string) public assetManagementCompany;

    event propertyOwnerAdded(address indexed propertyOwner);
    event propertyOwnerRemoved(address indexed propertyOwner);

    event custodianAdded(address indexed custodian);
    event custodianRemoved(address indexed custodian);

    event marketMakerAdded(address indexed marketMaker);
    event marketMakerRemoved(address indexed marketMaker);    

    event investorAdded(address indexed investor);
    event investorRemoved(address indexed investor);

    event taxAdviserAdded(address indexed taxAdviser);
    event taxAdviserRemoved(address indexed taxAdviser);

    event fundAdministratorAdded(address indexed fundAdministrator);
    event fundAdministratorRemoved(address indexed fundAdministrator);

    event realEstateValuerAdded(address indexed realEstateValuer);
    event realEstateValuerRemoved(address indexed realEstateValuer);

    event legalCouncilAdded(address indexed legalCouncils);
    event legalCouncilRemoved(address indexed legalCouncils);

    event financialAdviserAdded(address indexed financialAdviser);
    event financialAdvisorRemoved(address indexed financialAdviser);

    event techAdvisorAdded(address indexed techAdviser);
    event techAdvisorRemoved(address indexed techAdviser);

    event assetManagementCompanyAdded(address indexed assetManagementCompany);
    event assetManagementCompanyRemoved(address indexed assetManagementCompany);


    
    function addPropertyOwner(address _propertyOwner, string memory _doc) public isAdmin {
        require(bytes(propertyOwners[_propertyOwner]).length == 0, "Land Owner already exists");
        propertyOwners[_propertyOwner] = _doc;
        emit propertyOwnerAdded(_propertyOwner);
    }

    function removePropertyOwner(address _propertyOwner) public isAdmin { 
        require(bytes(propertyOwners[_propertyOwner]).length != 0, "Land Owner does not exists");
        delete propertyOwners[_propertyOwner];
        emit propertyOwnerRemoved(_propertyOwner);
    }

    function addCustodian(address _custodian, string memory _doc) public isAdmin {
        require(bytes(custodians[_custodian]).length == 0, "Custodian already exists");
        custodians[_custodian] = _doc;
        emit custodianAdded(_custodian);
    }
    function removeCustodian(address _custodian) public isAdmin {
        require(bytes(custodians[_custodian]).length != 0, "Custodian does not exist");
        delete custodians[_custodian];
        emit custodianRemoved(_custodian);
    }

    function addMarketMaker(address _marketMaker, string memory _doc) public isAdmin {
        require(bytes(marketMakers[_marketMaker]).length == 0, "market maker already exists");
        marketMakers[_marketMaker] = _doc;
        emit marketMakerAdded(_marketMaker);
    }
    function removeMarketMaker(address _marketMaker) public isAdmin {
        require(bytes(marketMakers[_marketMaker]).length != 0, "market maker does not exist");
        delete marketMakers[_marketMaker];
        emit marketMakerRemoved(_marketMaker);
    }  

    function addInvestor(address _investor, string memory _doc) public isAdmin {
        require(bytes(investors[_investor]).length == 0, "investor already exists");
        investors[_investor] = _doc;
        emit investorAdded(_investor);
    }

    function removeInvestor(address _investor) public isAdmin { 
        require(bytes(investors[_investor]).length != 0, "investor does not exist");
        delete investors[_investor];
        emit investorRemoved(_investor);
    }

    function addTaxAdvisor(address _taxAdvisor, string memory _doc) public isAdmin {
        require(bytes(taxAdvisors[_taxAdvisor]).length == 0, "tax Adviser already exists");
        taxAdvisors[_taxAdvisor] = _doc;
        emit taxAdviserAdded(_taxAdvisor);
    }

    function removeTaxAdvisor(address _taxAdvisor) public isAdmin {
        require(bytes(taxAdvisors[_taxAdvisor]).length != 0, "tax Adviser does not exist");
        delete taxAdvisors[_taxAdvisor];
        emit taxAdviserRemoved(_taxAdvisor);
    } 

    function addFundAdministrator(address _fundAdministrator, string memory _doc) public isAdmin {
        require(bytes(fundAdministrators[_fundAdministrator]).length == 0, "fund Administrator already exists");
        fundAdministrators[_fundAdministrator] = _doc;
        emit fundAdministratorAdded(_fundAdministrator);
    }

    function removeFundAdministrator(address _fundAdministrator) public isAdmin {
        require(bytes(fundAdministrators[_fundAdministrator]).length != 0, "fund Administrator does not exist");
        delete fundAdministrators[_fundAdministrator];
        emit fundAdministratorRemoved(_fundAdministrator);
    } 

    function addRealEstateValuer(address _realEstateValuer, string memory _doc) public isAdmin {
        require(bytes(realEstateValuers[_realEstateValuer]).length == 0, "Real Estate Valuer already exists");
        realEstateValuers[_realEstateValuer] = _doc;
        emit realEstateValuerAdded(_realEstateValuer);
    }

    function removeRealEstateValuer(address _realEstateValuers) public isAdmin {
        require(bytes(realEstateValuers[_realEstateValuers]).length != 0, "Real Estate Valuer does not exist");
        delete realEstateValuers[_realEstateValuers];
        emit realEstateValuerRemoved(_realEstateValuers);
    } 

    function addlegalCouncil(address _legalCouncil, string memory _doc) public isAdmin {
        require(bytes(legalCouncils[_legalCouncil]).length == 0, "Real Estate Valuer already exists");
        legalCouncils[_legalCouncil] = _doc;
        emit legalCouncilAdded(_legalCouncil);
    }

    function removelegalCouncil(address _legalCouncil) public isAdmin {
        require(bytes(legalCouncils[_legalCouncil]).length != 0, "Real Estate Valuer does not exist");
        delete legalCouncils[_legalCouncil];
        emit legalCouncilRemoved(_legalCouncil);
    }
    
    function addFinancialAdvisor(address _financialAdvisor, string memory _doc) public isAdmin {
        require(bytes(financialAdvisors[_financialAdvisor]).length == 0, "Financial Adviser already exists");
        financialAdvisors[_financialAdvisor] = _doc;
        emit financialAdviserAdded(_financialAdvisor);
    }

    function removefinancialAdvisor(address _financialAdvisor) public isAdmin {
        require(bytes(financialAdvisors[_financialAdvisor]).length != 0, "Financial Adviser does not exist");
        delete financialAdvisors[_financialAdvisor];
        emit financialAdvisorRemoved(_financialAdvisor);
    }

    function addTechAdvisor(address _techAdvisor, string memory _doc) public isAdmin {
        require(bytes(techAdvisor[_techAdvisor]).length == 0, "Tech Adviser already exists");
        techAdvisor[_techAdvisor] = _doc;
        emit techAdvisorAdded(_techAdvisor);
    }

    function removeTechAdvisor(address _techAdvisor) public isAdmin {
        require(bytes(techAdvisor[_techAdvisor]).length != 0, "Tech Adviser does not exist");
        delete techAdvisor[_techAdvisor];
        emit techAdvisorRemoved(_techAdvisor);
    }

    function addAssetManagementCompany(address _assetManagementCompany, string memory _doc) public isAdmin {
        require(bytes(assetManagementCompany[_assetManagementCompany]).length == 0, "Tech Adviser already exists");
        assetManagementCompany[_assetManagementCompany] = _doc;
        emit assetManagementCompanyAdded(_assetManagementCompany);
    }

    function removeAssetManagementCompany(address _assetManagementCompany) public isAdmin {
        require(bytes(assetManagementCompany[_assetManagementCompany]).length != 0, "Tech Adviser does not exist");
        delete assetManagementCompany[_assetManagementCompany];
        emit assetManagementCompanyRemoved(_assetManagementCompany);
    }

    function isValidPropertyOwner(address _propertyOwner) public view returns(bool){
        if(bytes(propertyOwners[_propertyOwner]).length == 0){
            return false;
        }
        else{
            return true;
        }
    } 

    function isValidCustodian(address _custodian) public view returns(bool){
        if(bytes(custodians[_custodian]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

    function isValidMarketMaker(address _marketMaker) public view returns(bool){
        if(bytes(marketMakers[_marketMaker]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

    function isValidInvestor(address _investor) public view returns(bool){
        if(bytes(investors[_investor]).length == 0){
            return false;
        }
        else{
            return true;
        }
    } 

    function isValidTaxAdvisor(address _taxAdvisor) public view returns(bool){
        if(bytes(taxAdvisors[_taxAdvisor]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

    function isValidFundAdministrator(address _fundAdministrator) public view returns(bool){
        if(bytes(fundAdministrators[_fundAdministrator]).length == 0){
            return false;
        }
        else{
            return true;
        }
    } 

    function isValidRealEstateValuer(address _realEstateValuer) public view returns(bool){
        if(bytes(realEstateValuers[_realEstateValuer]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

    function isValidLegalCounsel(address _legalCouncil) public view returns(bool){
        if(bytes(legalCouncils[_legalCouncil]).length == 0){
            return false;
        }
        else{
            return true;
        }
    } 

    function isValidFinancialAdvisor(address _financialAdvisor) public view returns(bool){
        if(bytes(financialAdvisors[_financialAdvisor]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

    function isValidTechAdvisor(address _techAdvisor) public view returns(bool){
        if(bytes(techAdvisor[_techAdvisor]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }
     
    function isValidAssetManagementCompany(address _assetManagementCompany) public view returns(bool){
        if(bytes(assetManagementCompany[_assetManagementCompany]).length == 0){
            return false;
        }
        else{
            return true;
        }
    }

}
	