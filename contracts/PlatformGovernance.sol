// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";

contract PlatformGovernance is Ownable {
    
    mapping(address => bool) public admins;
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    constructor() {
        admins[_msgSender()] = true;
    }

    function addAdmin(address _admin) external onlyOwner {
        require(!admins[_admin], "Admin already exists");
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }  

    function removeAdmin(address _admin) external onlyOwner {
        require(admins[_admin], "Admin does not exist");
        require(_admin != _msgSender(), "Owner cannot be removed as admin");
        delete admins[_admin];
        emit AdminRemoved(_admin);
    }

    modifier isAdmin() {
        require(admins[_msgSender()], "AdminApproval: caller is not the admin");
        _;
    }
}
