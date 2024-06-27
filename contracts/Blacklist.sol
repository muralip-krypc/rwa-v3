// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Blacklist {
    mapping(address => bool) public blacklist;

    function addToBlacklist(address _investor) external {
        blacklist[_investor] = true;
    }

    function removeFromBlacklist(address _investor) external {
        blacklist[_investor] = false;
    }

    function isBlacklisted(address _investor) external view returns (bool) {
        return blacklist[_investor];
    }
}
