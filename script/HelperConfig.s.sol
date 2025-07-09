// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMAL = 8;
    int256 public constant INITIAL_PRICE = 3000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaNetwork = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaNetwork;
    }

    function getMainnetEthConfig() private pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainNetwork = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethMainNetwork;
    }

    function getAnvilConfig() private returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } else {
            vm.startBroadcast();
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
                DECIMAL,
                INITIAL_PRICE
            );
            vm.stopBroadcast();

            NetworkConfig memory anvilConfig = NetworkConfig({
                priceFeed: address(mockPriceFeed)
            });
            return anvilConfig;
        }
    }
}
