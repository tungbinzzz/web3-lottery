// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {VRFConsumerBaseV2Plus} from "../lib/chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "../lib/chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
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

contract Lottery is VRFConsumerBaseV2Plus {
    /*//////////////////////////////////////////////////////////////
                               ERRORS
    //////////////////////////////////////////////////////////////*/
    error Lottery__InvalidEntranceFee();
    error Lottery__NotOpen();

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
    //Chainlink VRF
    uint256 private immutable i_subscriptionId;

    bytes32 private immutable s_keyHash;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant requestConfirmations = 3;
    uint32 private constant numWords = 1;

    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/
    event LotteryEntered(address player);
    event LotteryRequested(uint256 requestId);

    /*//////////////////////////////////////////////////////////////
                                FUNCTION
    //////////////////////////////////////////////////////////////*/
    constructor(
        uint256 entranceFee,
        uint256 subscriptionId,
        address vrfCoordinator,
        bytes32 keyHash,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        s_lotteryState = LotteryState.OPEN; // Initialize the lottery state to OPEN
        //Deloyed
        i_subscriptionId = subscriptionId;
    
        s_keyHash = keyHash;
        i_callbackGasLimit = callbackGasLimit;
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

    function requestLottery() public returns (uint256 requestId) {
        //Check - Validate the lottery state

        //Effect - Update state variables
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
    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {

       
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
}
