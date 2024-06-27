// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InvestorTokenLimit {
    uint256 public maxTokenLimit;

    constructor(uint256 _maxTokenLimit) {
        maxTokenLimit = _maxTokenLimit;
    }

    function validateTokenLimit(uint256 _amount) external view returns (bool) {
        return _amount <= maxTokenLimit;
    }
}
