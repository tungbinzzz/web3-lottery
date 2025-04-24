// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {LOCAL_CHAIN_ID, SEPOLIA_CHAIN_ID, BASE_FEE, GAS_PRICE, WER_PER_UNIT} from "./Constants.sol";
import {VRFCoordinatorV2_5Mock} from "../lib/chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {MockLinkToken} from "../lib/chainlink/contracts/src/v0.8/mocks/MockLinkToken.sol";

contract HelperConfig is Script {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error HelperConfig__InvalidChainId();

    struct NetworkConfig {
        address vrfCoordinator;
        bytes32 keyHash;
        uint256 subscriptionId;
        address account;
        address linkToken;
    }

    NetworkConfig public localNetworkConfig;
    mapping(uint256 => NetworkConfig) public networkConfigs;

    constructor() {
        networkConfigs[SEPOLIA_CHAIN_ID] = getSepoliaNetworkConfig();
    }

    function getConfig() public returns (NetworkConfig memory) {
        return getConfigByChainId(block.chainid);
    }

    function getConfigByChainId(uint256 chainId) public returns (NetworkConfig memory) {
        if(networkConfigs[chainId].vrfCoordinator != address(0)) {
            return networkConfigs[chainId];
        } else if (chainId == LOCAL_CHAIN_ID) {
            return getOrCreateLocalConfig();
        } else {
            revert HelperConfig__InvalidChainId();
        }
    }

    function getSepoliaNetworkConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 79087689324744884936759613458615524292034488023227621584195293937990173319143,
            account: 0xc2bc5632414c537e4D640560972909175ce21dDB,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getOrCreateLocalConfig() public returns (NetworkConfig memory) {
        if (localNetworkConfig.vrfCoordinator != address(0)) {
            return localNetworkConfig;
        }

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(BASE_FEE, GAS_PRICE, WER_PER_UNIT);
        uint256 subscriptionId = vrfCoordinatorMock.createSubscription();
        MockLinkToken linkToken = new MockLinkToken();
        vm.stopBroadcast();
        localNetworkConfig = NetworkConfig({
            vrfCoordinator: address(vrfCoordinatorMock),
            keyHash: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: subscriptionId,
            account: 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38, //Default sender
            linkToken: address(linkToken)
        });
        return localNetworkConfig;
    }
}
