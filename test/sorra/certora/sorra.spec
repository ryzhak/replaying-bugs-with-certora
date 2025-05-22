using MockERC20 as rewardToken;

rule withdrawIntegrity() {
    env e;
    uint256 amount;

    // user's balance < 100 mln
    require rewardToken.balanceOf(e, e.msg.sender) < 100000000000000000000000000;
    // withdraw amount < 100 mln
    require amount < 100000000000000000000000000;
    // users positions < 100 mln
    require rewardToken.balanceOf(e, currentContract) < 100000000000000000000000000;

    // no vault extensions
    require currentContract.vaultExtension(e) == 0;
    // there already exists some deposit
    require rewardToken.balanceOf(e, currentContract) == currentContract.positions[e.msg.sender].totalAmount;
    // pending rewards exist (i.e. some time passed)
    require getPendingRewards(e, e.msg.sender) > 1;
    // current contract can't be a sender
    require e.msg.sender != currentContract;

    uint256 contractBalanceBefore = rewardToken.balanceOf(e, currentContract);
    uint256 userBalanceBefore = rewardToken.balanceOf(e, e.msg.sender);
    uint256 pendingRewardsBefore = getPendingRewards(e, e.msg.sender);
    uint256 userDepositedAmountBefore = currentContract.positions[e.msg.sender].totalAmount;

    withdraw(e, amount);

    uint256 contractBalanceAfter = rewardToken.balanceOf(e, currentContract);
    uint256 userBalanceAfter = rewardToken.balanceOf(e, e.msg.sender);
    uint256 pendingRewardsAfter = getPendingRewards(e, e.msg.sender);
    uint256 userDepositedAmountAfter = currentContract.positions[e.msg.sender].totalAmount;

    assert (amount + pendingRewardsBefore) == (userBalanceAfter - userBalanceBefore + pendingRewardsAfter), "User can not withdraw more than expected";
}
