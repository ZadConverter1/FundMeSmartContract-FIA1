// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator as mock} from "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    int256 constant INITIAL_ANSWER = 3050e18;
    uint8 constant DECIMAL = 8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainnetConfig();
        } else {
            activeNetworkConfig = getAnvilDefaulConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaConfig() internal pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig;
        sepoliaConfig.priceFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        return sepoliaConfig;
    }

    function getEthMainnetConfig()
        internal
        pure
        returns (NetworkConfig memory)
    {
        NetworkConfig memory ethMainnetConfig;
        ethMainnetConfig.priceFeed = 0x5424384B256154046E9667dDFaaa5e550145215e;
        return ethMainnetConfig;
    }

    function getAnvilDefaulConfig() internal returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        mock con = new mock(DECIMAL, INITIAL_ANSWER);
        vm.stopBroadcast();

        NetworkConfig memory anvilDefaultConfig;
        anvilDefaultConfig.priceFeed = address(con);
        return anvilDefaultConfig;
    }
}
