// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Whitelist {
    mapping(address => bool) public whitelist;

    function addToWhitelist(address _investor) external {
        whitelist[_investor] = true;
    }

    function removeFromWhitelist(address _investor) external {
        whitelist[_investor] = false;
    }

    function isWhitelisted(address _investor) external view returns (bool) {
        return whitelist[_investor];
    }
}
