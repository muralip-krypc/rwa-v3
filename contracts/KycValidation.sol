// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KycValidation {
    mapping(address => bool) public kycVerified;

    function addKycVerified(address _investor) external {
        kycVerified[_investor] = true;
    }

    function removeKycVerified(address _investor) external {
        kycVerified[_investor] = false;
    }

    function isValidInvestor(address _investor) external view returns (bool) {
        return kycVerified[_investor];
    }
}
