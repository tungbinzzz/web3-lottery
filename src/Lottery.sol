// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
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

contract Lottery {
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

/*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/
event LotteryEntered(address indexed player, uint256 amount);

/*//////////////////////////////////////////////////////////////
                                FUNCTION
    //////////////////////////////////////////////////////////////*/
 constructor(uint256 entranceFee) {
     i_entranceFee = entranceFee;
 }

/*//////////////////////////////////////////////////////////////
                               PUBLIC FUNCTION
    //////////////////////////////////////////////////////////////*/
 function enterLottery() public payable {
    if(s_lotteryState != LotteryState.OPEN) {
        revert Lottery__NotOpen();
    }
    if(msg.value < i_entranceFee) {
        revert Lottery__InvalidEntranceFee();
    }
    s_rewardBalance += msg.value;
    s_players.push(msg.sender);

    emit LotteryEntered(msg.sender, msg.value);
 }

}
