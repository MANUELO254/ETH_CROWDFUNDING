// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8; // 2000 USD

    struct NetworkConfig {
        address dataFeed; // ETH/USD price feed address
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() internal pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaEthConfig = NetworkConfig({dataFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaEthConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetEthConfig = NetworkConfig({dataFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return mainnetEthConfig;
    }

    function getOrCreateAnvilEthConfig() internal returns (NetworkConfig memory) {
        if (activeNetworkConfig.dataFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockdataFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER); // 2000 USD

        vm.stopBroadcast();

        NetworkConfig memory anvilEthConfig = NetworkConfig({dataFeed: address(mockdataFeed)});
        return anvilEthConfig;
    }

    // Deploy mocks when we are on a local anvil chain
    // Keep track of contract addresses from the live network
}
