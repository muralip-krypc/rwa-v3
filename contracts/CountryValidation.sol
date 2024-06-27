// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CountryValidation {
    mapping(string => bool) public restrictedCountries;

    constructor(string[] memory _restrictedCountries) {
        for (uint i = 0; i < _restrictedCountries.length; i++) {
            restrictedCountries[_restrictedCountries[i]] = true;
        }
    }

    function isCountryRestricted(string memory _country) external view returns (bool) {
        return restrictedCountries[_country];
    }
}
