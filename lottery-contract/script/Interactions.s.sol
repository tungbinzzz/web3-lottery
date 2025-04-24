// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {Lottery} from "src/Lottery.sol";
import {ENTRANCE_FEE, CALLBACK_GAS_LIMIT, AUTOMATION_INTERVAL} from "./Constants.sol";
contract EnterLottery is Script {
    function enterLottery(address lotteryAddress) public {
        vm.startBroadcast();
        Lottery(lotteryAddress).enterLottery{value: ENTRANCE_FEE}();
        vm.stopBroadcast();
    }

    function run() external {
       // address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("Lottery", block.chainid);
        enterLottery(address(0x8c9207BaA0Eb7bA6F969C6da3Dd1Ec672e22B8b5));
    }
}