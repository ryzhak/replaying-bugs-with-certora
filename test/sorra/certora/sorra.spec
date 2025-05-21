using MockERC20 as rewardToken;

rule withdrawIntegrity() {
    env e;
    uint256 amount;

    require rewardToken.balanceOf(e, e.msg.sender) == 0;
    require rewardToken.balanceOf(e, currentContract) == currentContract.positions[e.msg.sender].totalAmount;
    require currentContract.vaultExtension(e) == 0;
    require getPendingRewards(e, e.msg.sender) > 1000000000000000000;
    require amount > 1000000000000000000;

    uint256 contractBalanceBefore = rewardToken.balanceOf(e, currentContract);
    uint256 userBalanceBefore = rewardToken.balanceOf(e, e.msg.sender);
    uint256 pendingRewardsBefore = getPendingRewards(e, e.msg.sender);
    uint256 userDepositedAmountBefore = currentContract.positions[e.msg.sender].totalAmount;

    withdraw(e, amount);

    uint256 contractBalanceAfter = rewardToken.balanceOf(e, currentContract);
    uint256 userBalanceAfter = rewardToken.balanceOf(e, e.msg.sender);
    uint256 pendingRewardsAfter = getPendingRewards(e, e.msg.sender);
    uint256 userDepositedAmountAfter = currentContract.positions[e.msg.sender].totalAmount;

    assert userBalanceAfter + pendingRewardsAfter <= userDepositedAmountBefore + pendingRewardsBefore, "User can not withdraw more than expected";
}
