// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "interfaces//IStaking.sol";
import "interfaces/IRewards.sol";

contract Rewards is IRewards, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    IStaking public staking;
    IERC20 public immutable rewardsToken;
    address public rewardsDistribution;

    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor(
        address _stakingContract,
        address _rewardsToken,
        address _rewardsDistribution
    ) {
        staking = IStaking(_stakingContract);
        rewardsToken = IERC20(_rewardsToken);
        rewardsDistribution = _rewardsDistribution;
    }

    // --- Implemented Interface Functions ---
    function notifyRewardAmount(uint256 reward) external override nonReentrant {
        require(msg.sender == rewardsDistribution, "Unauthorized");
        _updateRewards();
        
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        
        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance / rewardsDuration, "Reward too high");
        
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
    }

    function getReward() public override nonReentrant {
        _updateRewardsForUser(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
        }
    }

    function earned(address account) public view override returns (uint256) {
        return (staking.balanceOf(account) * 
            (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18 + rewards[account];
    }

    function rewardPerToken() public view override returns (uint256) {
        if (staking.totalSupply() == 0) return rewardPerTokenStored;
        return rewardPerTokenStored + (
            (lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18 / staking.totalSupply()
        );
    }

    function setRewardsDistribution(address newDistribution) external override onlyOwner {
        rewardsDistribution = newDistribution;
    }

    // --- Internal Helpers ---
    function _updateRewards() internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
    }

    function _updateRewardsForUser(address account) internal {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
    }

    function lastTimeRewardApplicable() internal view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }
}