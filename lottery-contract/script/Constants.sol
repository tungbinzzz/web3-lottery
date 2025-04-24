// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

uint256 constant ENTRANCE_FEE = 0.01 ether;
uint256 constant GAS_LIMIT = 1000000;
uint32 constant CALLBACK_GAS_LIMIT = 100000;

//Chain ID
uint256 constant LOCAL_CHAIN_ID = 31337;
uint256 constant SEPOLIA_CHAIN_ID = 11155111;

//Chainlink VRF V2.5 Mock
uint96 constant BASE_FEE = 0.25 ether; //Số tiền phải trả cho mỗi lần lấy random
uint96 constant GAS_PRICE = 1e9; // 0.000000001 LINK per gas khi gọi lệnh requestRandomWords
int256 constant WER_PER_UNIT = 4e15; //LINK/ETH price

//Chainlinl automation
uint256 constant AUTOMATION_INTERVAL = 30; //30 seconds
