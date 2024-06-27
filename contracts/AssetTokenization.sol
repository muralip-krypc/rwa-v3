
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC1155Supply.sol";

interface IkycInvestor{
    function isValidInvestor(address _investor) external view returns(bool);
}

contract AssetTokenization is ERC1155Supply {

    //allAddressToTokenId[tokenId].push(owner);
    mapping(uint => address[]) public allAddressToTokenId;
    mapping(uint => mapping(address => uint)) public allAddressToTokenIdIndex;
    address public kycContract;

    constructor(string memory _uri,address _custodian,uint256 _tokenId, uint256 _initialSupply, bytes memory _data, address _kycContract) ERC1155(_uri){
        _mint(_custodian, _tokenId, _initialSupply, _data);
        kycContract = _kycContract;
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        bool receiverKYCstatus = IkycInvestor(kycContract).isValidInvestor(to);
        require(receiverKYCstatus, "to address is not KYC verified");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) public virtual override {
        bool receiverKYCstatus = IkycInvestor(kycContract).isValidInvestor(to);
        require(receiverKYCstatus, "to address is not KYC verified");
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for(uint256 i; i < ids.length; i++) {
            uint id = ids[i];
            uint tokenCountFrom;
            uint tokenCountTo;
            if(from != address(0)){
                tokenCountFrom = balanceOf(from,id);
            }if(to != address(0)){
                tokenCountTo = balanceOf(to,id);
            }
            uint len = allAddressToTokenId[id].length;
            if (from == address(0) && to != address(0)) {
                if(tokenCountTo == 0){                    
                    addTokenToArray(id,to,len);   
                } 
            }
            else if(to == address(0) && from != address(0)){
                uint tokenLeft = tokenCountFrom - amounts[i];
                if(tokenLeft == 0){
                    alterOwnerPos(id,from,len);     
                }
            } 
            else if (from != to) {
                uint tokenLeft = tokenCountFrom - amounts[i];
                if(tokenLeft == 0){
                    alterOwnerPos(id,from,len);      
                }
                else{
                    if(tokenCountTo == 0){
                        addTokenToArray(id,to,len);  
                    }
                }
            }
        }
    }

    function getAllTokenOwnerListByTokenId(uint _tokenId) public view returns(address[] memory){
        return allAddressToTokenId[_tokenId];
    }

    function addTokenToArray(uint id,address to, uint len ) internal {
        allAddressToTokenIdIndex[id][to] = len;
        allAddressToTokenId[id].push(to);     
    }

    function alterOwnerPos(uint id,address from, uint len) internal{
        uint pos = allAddressToTokenIdIndex[id][from];
        address owner = allAddressToTokenId[id][len -1];
        allAddressToTokenId[id][pos] = allAddressToTokenId[id][len -1];
        allAddressToTokenIdIndex[id][owner] = pos; 
        allAddressToTokenId[id].pop();
        delete allAddressToTokenIdIndex[id][from];
    }

}

