// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {ENTRANCE_FEE} from "./Constants.sol";

contract DeployLottery is Script {
    function run() external {
        deployLottery();
    }

    function deployLottery() public returns (Lottery) {
        vm.startBroadcast();
        Lottery lottery = new Lottery(ENTRANCE_FEE);
        vm.stopBroadcast();
        return lottery;
    }
}
