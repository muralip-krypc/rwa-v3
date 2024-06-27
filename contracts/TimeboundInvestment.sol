// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TimeBoundInvestment {
    uint256 public saleStartTime;
    uint256 public saleEndTime;

    function setSalePeriod(uint256 _start, uint256 _end) external {
        saleStartTime = _start;
        saleEndTime = _end;
    }

    function isSalePeriodActive() external view returns (bool) {
        return block.timestamp >= saleStartTime && block.timestamp <= saleEndTime;
    }
}
