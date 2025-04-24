// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
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
    event LotteryRequested(uint256 indexed requestId);
    event WinnerPicked(address winner, uint256 balance);

    function setUp() external {
        DeployLottery deployLottery = new DeployLottery();
        (lottery, helperConfig) = deployLottery.deployLottery();
        config = helperConfig.getConfig();
        vm.deal(player, INIT_AMOUNT);

        //Setting up Mock Link Token
        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startPrank(config.account);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).addConsumer(config.subscriptionId, address(lottery));
            MockLinkToken(config.linkToken).setBalance(config.account, 100 ether);
            VRFCoordinatorV2_5Mock(config.vrfCoordinator).fundSubscription(config.subscriptionId, 100 ether);
            vm.stopPrank();
        }
    }

    modifier playerInLotteryAndTimePassed() {
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        vm.roll(block.number + 1);
        vm.warp(block.number + AUTOMATION_INTERVAL + 1);

        _;
    }

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
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
        //Tạo người chơi
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();
        //uint256 requestId = lottery.requestLottery();

        //Revert if lottery is not open
        vm.expectRevert(Lottery.Lottery__NotOpen.selector);
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        vm.expectEmit();
        emit WinnerPicked(player, ENTRANCE_FEE);
        //VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(requestId, address(lottery)); // Simulate the VRF Coordinator fulfilling the request

        assertEq(player, lottery.getRecentWinner());
        assertEq(lottery.getWinnerBalance(player), ENTRANCE_FEE);
        assert(Lottery.LotteryState.OPEN == lottery.getLotteryState());
        assertEq(0, lottery.getPlayersLength());
        assertEq(0, lottery.getRewardBalance());
    }

    function test_checkUpkeep() public skipFork {
        //False if player is not in lottery
        (bool upkeepNeeded,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded);

        //Player in lottery
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        //False if time is not passed
        (upkeepNeeded,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded);

        //Time passed
        vm.roll(block.number + 1);
        vm.warp(block.number + AUTOMATION_INTERVAL + 1);

        //True if lottery is open
        (upkeepNeeded,) = lottery.checkUpkeep("");
        assertTrue(upkeepNeeded);

        //Run performUpkeep
        lottery.performUpkeep("");

        //False if lottery is not open
        (upkeepNeeded,) = lottery.checkUpkeep("");
        assertFalse(upkeepNeeded);
    }

    function test_performUpkeep() public playerInLotteryAndTimePassed skipFork {
        //Run performUpkeep
        vm.recordLogs();

        lottery.performUpkeep("");
        //Assert
        assertEq(block.timestamp, lottery.getLastUpkeepTimeStamp());

        //Revert if lottery is not open
        vm.expectRevert(Lottery.Lottery__NotOpen.selector);
        vm.prank(player);
        lottery.enterLottery{value: ENTRANCE_FEE}();

        Vm.Log[] memory entries = vm.getRecordedLogs();

        uint256 requestId = uint256(entries[1].topics[1]);
        console.log("requestId: ", requestId);
        VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(requestId, address(lottery)); // Simulate the VRF Coordinator fulfilling the request

        assertEq(player, lottery.getRecentWinner());
        assertEq(lottery.getWinnerBalance(player), ENTRANCE_FEE);
        assert(Lottery.LotteryState.OPEN == lottery.getLotteryState());
        assertEq(0, lottery.getPlayersLength());
        assertEq(0, lottery.getRewardBalance());
    }

    function test_can_claim() public playerInLotteryAndTimePassed skipFork {
        //revert if not have a balance
        vm.expectRevert(Lottery.Lottery__NotEnoughBalance.selector);
        vm.prank(player);
        lottery.windrawReward();

        //Chainlink automation and VRF
        vm.recordLogs();
        lottery.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        uint256 requestId = uint256(entries[1].topics[1]);
        VRFCoordinatorV2_5Mock(config.vrfCoordinator).fulfillRandomWords(requestId, address(lottery)); // Simulate the VRF Coordinator fulfilling the request

        uint256 beforeBalance = player.balance;
            
        vm.prank(player);
        lottery.windrawReward();

        uint256 afterBalance = player.balance;
        assertEq(afterBalance, beforeBalance + ENTRANCE_FEE);
    }
}
