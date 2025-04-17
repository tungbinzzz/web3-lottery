// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "../../src/Lottery.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import "script/Constants.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    address public player = makeAddr("player");
    uint256 public constant INIT_AMOUNT = 10 ether;

    event LotteryEntered(address player);

    function setUp() external {
        DeployLottery deployLottery = new DeployLottery();
        lottery = deployLottery.deployLottery();
        vm.deal(player, INIT_AMOUNT);
    }

    function test_setUp() public view {
        assertEq(lottery.getEntranceFee(), ENTRANCE_FEE);
    }

    function test_enterLottery() public {
        //Revert if invalid entrance fee
        vm.expectRevert(Lottery.Lottery__InvalidEntranceFee.selector);
        lottery.enterLottery();

        //Arrange
        

        //Action
        vm.expectEmit();
        emit LotteryEntered(player);
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        //Assert 
        assertEq(player.balance, INIT_AMOUNT - ENTRANCE_FEE);
        assertEq(lottery.getRewardBalance(), ENTRANCE_FEE);
        assertEq(lottery.getPlayerByIndex(0), player);
        assertEq(lottery.getPlayersLength(), 1);
    }
}
