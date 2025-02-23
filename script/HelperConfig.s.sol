// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }

    // if you want to add more networks, you can add them here, just follow the below pattern
    // function getYourNetworkEthConfig() public pure returns (NetworkConfig memory) {
    //     NetworkConfig memory yourNetworkConfig = NetworkConfig({priceFeed: 0xYourPriceFeedAddress});
    //     replace YourNetwork with your network name
    //     replace YourPriceFeedAddress with your price feed address -> get it from https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
    //     and select the network you want to use and search for ETH/USD price feed address
    //     return yourNetworkConfig;
    // }
    // and don't forget to add your network to the constructor, adding an if statement with the chain id of the network
}
