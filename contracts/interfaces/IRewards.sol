// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IRewards {
    function notifyRewardAmount(uint256 reward) external;
    function getReward() external;
    function earned(address account) external view returns (uint256);
    function rewardPerToken() external view returns (uint256);
    function setRewardsDistribution(address newDistribution) external;
}