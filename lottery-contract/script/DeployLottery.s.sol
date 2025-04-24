// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Lottery} from "../src/Lottery.sol";
import {ENTRANCE_FEE, CALLBACK_GAS_LIMIT, AUTOMATION_INTERVAL} from "./Constants.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployLottery is Script {
    function run() external {
        deployLottery();
    }

    function deployLottery() public returns (Lottery, HelperConfig) {

        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        Lottery lottery = new Lottery(
            ENTRANCE_FEE,
            config.subscriptionId,
            config.vrfCoordinator,
            config.keyHash,
            CALLBACK_GAS_LIMIT,
            AUTOMATION_INTERVAL
        );
        vm.stopBroadcast();
        return (lottery, helperConfig);
    }
}
