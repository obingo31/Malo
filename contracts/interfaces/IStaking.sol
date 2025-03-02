// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IStaking {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function stake(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function pause() external;
    function unpause() external;
}