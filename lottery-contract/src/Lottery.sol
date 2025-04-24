// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFConsumerBaseV2Plus} from "../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "../lib/chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

/// @title Lottery Contract
/// @author tungbinzzz
/// @notice User can create a lottery and join a lottery
/// @dev This contract is used to create and manage lotteries

contract Lottery is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/
    error Lottery__InvalidEntranceFee();
    error Lottery__NotOpen();
    error Lottery__NotEnoughPlayers();
    error Lottery__TransferFailed();
    error Lottery__UpkeepNotNeeded();
    error Lottery__NotEnoughBalance();

    /*//////////////////////////////////////////////////////////////
                               TYPE DECLARATIONS
    //////////////////////////////////////////////////////////////*/
    enum LotteryState {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }

    /*//////////////////////////////////////////////////////////////
                               STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    LotteryState private s_lotteryState;
    uint256 private immutable i_entranceFee;
    uint256 private s_rewardBalance;
    address[] private s_players;
    address private s_recentWinner;
    mapping(address winner => uint256 balance) private s_winnerBalances;
    //Chainlink VRF
    uint256 private immutable i_subscriptionId;
    bytes32 private immutable s_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant requestConfirmations = 3;
    uint32 private constant numWords = 1;
    //Chainlink automation
    uint256 public immutable i_interval;
    uint256 public s_lastTimeStamp;

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/
    event LotteryEntered(address player);
    event LotteryRequested(uint256 indexed requestId);
    event WinnerPicked(address winner, uint256 balance);
    event LotteryClaimed(address winner, uint256 balance);

    /*//////////////////////////////////////////////////////////////
                                FUNCTION
    //////////////////////////////////////////////////////////////*/
    constructor(
        uint256 entranceFee,
        uint256 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        uint32 callbackGasLimit,
        uint256 interval
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        s_lotteryState = LotteryState.OPEN; // Initialize the lottery state to OPEN
        //Deloyed
        i_subscriptionId = subscriptionId;

        s_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
        i_interval = interval;
    }

    /*//////////////////////////////////////////////////////////////
                               PUBLIC FUNCTION
    //////////////////////////////////////////////////////////////*/

    // CEI - Check, Effect, Interaction
    function enterLottery() public payable {
        //Check - Validate the entrance fee and lottery state
        if (s_lotteryState != LotteryState.OPEN) {
            revert Lottery__NotOpen();
        }
        if (msg.value < i_entranceFee) {
            revert Lottery__InvalidEntranceFee();
        }

        //Effect - Update state variables
        s_rewardBalance += msg.value;
        s_players.push(msg.sender);

        //Interaction - Emit event
        // Emit the event after updating the state variables
        emit LotteryEntered(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                            PRIVATE FUNCTION
    //////////////////////////////////////////////////////////////*/

    function _requestLottery() private returns (uint256 requestId) {
        //Check - Validate the lottery state

        //Effect - Update state variables
        if (s_players.length == 0) {
            revert Lottery__NotEnoughPlayers();
        }
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: i_callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );

        s_lotteryState = LotteryState.CLOSED;

        //Interaction - Request random number from Chainlink VRF

        emit LotteryRequested(requestId);
    }

    // fulfillRandomWords function
    function fulfillRandomWords(uint256, /*requestId,*/ uint256[] calldata randomWords) internal override {
        uint256 winnerIndex = randomWords[0] % s_players.length;
        address winnerAddr = s_players[winnerIndex];
        uint256 winnerBalance = s_rewardBalance;

        s_recentWinner = winnerAddr;
        s_winnerBalances[winnerAddr] += winnerBalance;
        s_lotteryState = LotteryState.OPEN; // Reset the lottery state to OPEN
        s_rewardBalance = 0; // Reset the reward balance
        delete s_players; // Clear the players array

        emit WinnerPicked(winnerAddr, winnerBalance);
    }

    function checkUpkeep(bytes memory /* checkData */ )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */ )
    {
        bool isTimePassed = (block.timestamp - s_lastTimeStamp) > i_interval;
        bool hasPlayers = s_players.length > 0;
        bool isLotteryOpen = s_lotteryState == LotteryState.OPEN;

        upkeepNeeded = (isTimePassed && hasPlayers && isLotteryOpen); // Check if upkeep is needed

        return (upkeepNeeded, "0x0"); // Return the upkeepNeeded and performData
    }

    function windrawReward() public {
        //Checks
        uint256 winnerBalance = s_winnerBalances[msg.sender];
        if (winnerBalance <= 0) {
            revert Lottery__NotEnoughBalance();
        }
        //Effects
        s_winnerBalances[msg.sender] = 0; // Reset the winner balance for the user
        (bool success,) = payable(msg.sender).call{value: winnerBalance}("");
        if (!success) {
            revert Lottery__TransferFailed();
        }
        //Interaction
        s_winnerBalances[msg.sender] = 0; // Update the reward balance
        emit LotteryClaimed(msg.sender, winnerBalance); // Emit the event after the transfer
    }

    function performUpkeep(bytes calldata /* performData */ ) external override {
        (bool upkeepNeeded,) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert Lottery__UpkeepNotNeeded();
        }
        //Update the last time stamp
        s_lastTimeStamp = block.timestamp;
        _requestLottery();
        // We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function
    }

    /*//////////////////////////////////////////////////////////////
                            GETTER FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getRewardBalance() public view returns (uint256) {
        return s_rewardBalance;
    }

    function getPlayerByIndex(uint256 index) public view returns (address) {
        return s_players[index];
    }

    function getPlayersLength() public view returns (uint256) {
        return s_players.length;
    }

    function getVRFCoordinator() public view returns (address) {
        return address(s_vrfCoordinator);
    }

    function getRecentWinner() public view returns (address) {
        return s_recentWinner;
    }

    function getWinnerBalance(address winner) public view returns (uint256) {
        return s_winnerBalances[winner];
    }

    function getLotteryState() public view returns (LotteryState) {
        return s_lotteryState;
    }

    function getLastUpkeepTimeStamp() public view returns (uint256) {
        return s_lastTimeStamp;
    }
}
