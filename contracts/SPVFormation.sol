
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC1155TokenOnwerList{
    function getAllTokenOwnerListByTokenId(uint256 _tokenId) external view returns(address[] memory);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function totalSupply(uint256 id) external view returns (uint256);
}

interface IassetManagement{
    function assetOwnerAgreementDetails(address _assetContract) external view returns(address custodian,address assetOwner,
            uint256 totalAgreedMonthsTimeStamp,uint256 minDividendPay,uint256 maxDividendPay,
            uint256 commission,uint256 tokenPrice,string memory agreementDocument,bool isContractDeployed);
}

contract SPVFormation {

    address public fundAdministrator;
    address public assetContract;
    address public assetManagementContract;
    uint public tokenId;
    string doc1;
    string doc2;

    event dividendPaid(address indexed fundAdministrator, uint256 indexed amountPaid, uint256 timeOfPayment);
    
    constructor(address _assetManagementContract, address _assetContract, uint256 _tokenId, address _fundAdministrator,string memory _doc1, string memory _doc2){
        fundAdministrator = _fundAdministrator;
        assetManagementContract = _assetManagementContract;
        assetContract = _assetContract;
        tokenId = _tokenId;
        doc1 = _doc1;
        doc2 = _doc2;
    }

    function tokenShare() public view returns(address[] memory ownerList,uint[] memory noOfTokens,uint[] memory shares){
        IERC1155TokenOnwerList assetOwnerListinterface = IERC1155TokenOnwerList(assetContract);   
        ownerList = assetOwnerListinterface.getAllTokenOwnerListByTokenId(tokenId);  
        uint tokenTotalSupply = assetOwnerListinterface.totalSupply(tokenId);
        uint len = ownerList.length;
        require(tokenTotalSupply > 0, "Token supply must be greater than zero");
        noOfTokens = new uint[](len);
        shares = new uint[](len);
        for(uint i; i < len; i++){
            noOfTokens[i] = assetOwnerListinterface.balanceOf(ownerList[i], tokenId);
            shares[i] = (noOfTokens[i]*10000)/tokenTotalSupply;            
        }
    }

   function payDividend(uint256 _totalDividendPayAmount) public payable{
        require(_totalDividendPayAmount == msg.value,"amount send is less than total value");
        IassetManagement assetManagementInterface = IassetManagement(assetManagementContract);
        (,,,uint256 minDividendPay,uint256 maxDividendPay,,,,) = assetManagementInterface.assetOwnerAgreementDetails(assetContract);
        require(_totalDividendPayAmount >= minDividendPay && _totalDividendPayAmount <= maxDividendPay,"_totalDividendPayAmount is not in range");
        require(msg.sender == fundAdministrator,"caller is not the fund Administrator");
        (address[] memory ownerList,,uint[] memory shares) = tokenShare();
        uint ownerListLen = ownerList.length;
        for(uint i; i < ownerListLen; i++){
            uint share = shares[i];
            address assetOwner = ownerList[i];
            uint amount = (share * _totalDividendPayAmount)/10000; 
            payable(assetOwner).transfer(amount);
        } 
        emit dividendPaid(fundAdministrator,_totalDividendPayAmount,block.timestamp);       
    }

} 