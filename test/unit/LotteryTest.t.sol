// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Lottery} from "../../src/Lottery.sol";
import {DeployLottery} from "../../script/DeployLottery.s.sol";
import "script/Constants.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "../../lib/chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "../../lib/chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract LotteryTest is Test {
    Lottery public lottery;
    HelperConfig public helperConfig;
    HelperConfig.NetworkConfig config;

    address public player = makeAddr("player");
    uint256 public constant INIT_AMOUNT = 10 ether;

    event LotteryEntered(address player);

    function setUp() external {
        DeployLottery deployLottery = new DeployLottery();
        (lottery, helperConfig) = deployLottery.deployLottery();
        config = helperConfig.getConfig();
        vm.deal(player, INIT_AMOUNT);

        //Setting up Mock Link Token
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startPrank(config.account);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.subscriptionId, address(lottery));
            MockLinkToken(config.linkToken).setBalance(config.account, 10 ether);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(config.subscriptionId, 10 ether);
            vm.stopPrank();
        }
    }

    function test_setUp() public view {
        assertEq(lottery.getEntranceFee(), ENTRANCE_FEE);
        assertEq(lottery.getVRFCoordinator(), config.vrfCoordinator);
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

    function test_requestLottery() public {
        lottery.requestLottery();
    }
}
